//
//  AudioEpisode.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 12.09.22.
//

import AVFoundation

struct AudioSegmentTrack {
    
    var id: Int
    var url: URL
    var volume: Float
    var delay: Double
    var fadeIn: Double
    var fadeOut: Double
    
    var sourceFile: AVAudioFile
    var inputBuffer: AVAudioPCMBuffer
    var playerNode: AVAudioPlayerNode
    
    var sampleRate: Double {
        return sourceFile.processingFormat.sampleRate
    }
    
    var numberOfAudioSamples: AVAudioFramePosition {
        return sourceFile.length
    }
    
    var processingFormat: AVAudioFormat {
        return sourceFile.processingFormat
    }
    
    var startAudioTime: AVAudioTime {
        let numberOfSamplesEquivalentToDelay = AVAudioFramePosition(delay*sampleRate)
        let audioTime = AVAudioTime(sampleTime: numberOfSamplesEquivalentToDelay, atRate: sampleRate)
        return audioTime
    }
    
    /// Duration in seconds, including inital delay
    func calculateDurationIncludingDelay() -> Double {
        let fileDuration = Double(numberOfAudioSamples) / sampleRate
        return delay + fileDuration
    }
    
    init(id: Int, url: URL, volume: Float?, delay: Double?, fadeIn: Double?, fadeOut: Double?) {

        self.id = id
        self.url = url
        
        // set defauls
        self.volume = volume ?? 1.0
        self.delay = delay ?? 0.0
        self.fadeIn = fadeIn ?? 0.3
        self.fadeOut = fadeOut ?? 0.3
        
        // create AVAudioFile from URL
        do {
            sourceFile = try AVAudioFile(forReading: url)
        } catch {
            fatalError("Unable to load the source audio file: \(error.localizedDescription).")
        }
        
        // read into Buffer
        do {
            inputBuffer = AVAudioPCMBuffer(pcmFormat: sourceFile.processingFormat, frameCapacity: AVAudioFrameCount(sourceFile.length))!
            try sourceFile.read(into: inputBuffer)
        } catch {
            print("Error while reading file into buffer: \(error.localizedDescription)")
        }
        
        // create playerNode
        playerNode = AVAudioPlayerNode()
        
        // set player's initial volume
        playerNode.volume = volume!

        // debug
//        print("New track. sourceFile.processingFormat: \(sourceFile.processingFormat) inputBuffer.format: \(inputBuffer.format) playerNode.outputFormat(0): \(playerNode.outputFormat(forBus: 0))")
    }
    
    
}

struct AudioSegment {
    
    var id: Int
    var tracks = [AudioSegmentTrack]()
    
    mutating func addTrack(url: URL, volume: Float?, delay: Double?, fadeIn: Double?, fadeOut: Double?) {
        
        // the tracks's id is the next index in the array
        let trackId = tracks.endIndex
        
        let newTrack = AudioSegmentTrack(id: trackId, url: url, volume: volume, delay: delay, fadeIn: fadeIn, fadeOut: fadeOut)
        tracks.append(newTrack)
    }
    
    func calculateDuration() -> Double {
        
        var segmentDuration = 0.0
        
        for track in tracks {
            let trackDuration = track.calculateDurationIncludingDelay()
            segmentDuration = max(segmentDuration, trackDuration)
        }
        
        return segmentDuration
    }
}

struct AudioEpisode {
    
    /// Number of parallel audio tracks
    var outputSamplingRate: Double = 48000
    
    var audioEngine = AVAudioEngine()
    
    // stores sequence of segments
    var segments = [AudioSegment]()
    
    /// Creates a new audio segment and return its index
    mutating func addSegment() -> Int {
        
        // the segment's id is the next index in the array
        let segmentId = segments.endIndex
        
        // create segment
        let newSegment = AudioSegment(id: segmentId)
        segments.append(newSegment)
        
        return segmentId
    }
    
    mutating func addAudioTrack(toSegmentId segmentId: Int, url: URL, volume: Float?, delay: Double?, fadeIn: Double?, fadeOut: Double?) {
        
        if segmentId >= segments.endIndex {
            fatalError("Cannot add an audio track to non-existing segment with id \(segmentId)")
        }
        
        // retrieve affected segment
        var segment = segments[segmentId]
        
        // add track
        segment.addTrack(url: url, volume: volume, delay: delay, fadeIn: fadeIn, fadeOut: fadeOut)
        
        // replace old segment with updated segment
        segments[segmentId] = segment
        
        // duration
        let segmentDuration = segment.calculateDuration()
//        print("The duration of segment \(segmentId) is: \(segmentDuration)")
    }
    
    func startTimeOfTrack(withId trackId: Int, inSegmentWithId segmentId: Int) -> AVAudioTime {
        
        // sum up the duration of all previous Segments -> start of segment with <segmentId>
        var segmentStartInSeconds = 0.0
        for index in 0..<segmentId {
            segmentStartInSeconds += segments[index].calculateDuration()
        }
        
        // add delay
        let relevantSegment = segments[segmentId]
        let relevantTrack = relevantSegment.tracks[trackId]
        let trackDelay = relevantTrack.delay
        let trackStartInSeconds = segmentStartInSeconds + trackDelay
        
        // convert to AVAudioTime
        let sampleRate = relevantTrack.sampleRate
        let samplePosition = AVAudioFramePosition(trackStartInSeconds * sampleRate)
        let audioTime = AVAudioTime(sampleTime: samplePosition, atRate: sampleRate)
        
        // debug
//        print("trackId: \(trackId) segmentId: \(segmentId) segmentStart: \(segmentStartInSeconds) trackDelay: \(trackDelay) trackStart: \(trackStartInSeconds)")
//        print("sampleRate: \(sampleRate) samplePosition: \(samplePosition) audioTime: \(audioTime)")
        
        // return result
        return audioTime
    }
    
    func calculateEpisodeDuration() -> Double {
        
        var episodeDuration = 0.0
        
        for segment in segments {
            
            let segmentDuration = segment.calculateDuration()
            episodeDuration = max(episodeDuration, segmentDuration)
        }
 
        return episodeDuration
    }
    
    func render(outputfileName: String) -> URL {
        
        // store all audio players here
        //var playerNodes = [AVAudioPlayerNode]()
        
        // go throuch each segment
        for segment in segments {
            
            // go through each of the segment's tracks
            for track in segment.tracks {
                
                // get track's player
                let playerNode = track.playerNode
                
                // attach player to engine
                audioEngine.attach(playerNode)
                
                // connect to mixer
                audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: track.processingFormat)
                
                // schedule player's playback
                let startAudioTime = startTimeOfTrack(withId: track.id, inSegmentWithId: segment.id)
                playerNode.scheduleBuffer(track.inputBuffer, at: startAudioTime)
            }
        }
        
        // the audio format to use
        let outputFormat: AVAudioFormat = AVAudioFormat(standardFormatWithSampleRate: outputSamplingRate, channels: 2)!
        
        // setup engines for manual rendering
        do {
            // The maximum number of frames the engine renders in any single render call.
            let maxFrames: AVAudioFrameCount = 4096
            try audioEngine.enableManualRenderingMode(.offline, format: outputFormat, maximumFrameCount: maxFrames)
        } catch {
            fatalError("Enabling manual rendering mode failed: \(error).")
        }
        
        // start engine and players
        do {
            // prepare audio engine
            audioEngine.prepare()
            
            // start engine
            try audioEngine.start()
            
            // start all players at the same time
            var referenceSampleTime: AVAudioFramePosition?
            var sampleRateOfFirstPlayer: Double?
            let startDelay = 0.0
            
            for segment in segments {
                for track in segment.tracks {
                
                    // retrieve track's plasyerNode
                    let playerNode = track.playerNode
                    
                    // if this is the firstPlayer, referenceSampleTime is not yet defined
                    if referenceSampleTime == nil {
                        sampleRateOfFirstPlayer = playerNode.outputFormat(forBus: 0).sampleRate
                        referenceSampleTime = playerNode.lastRenderTime!.sampleTime + AVAudioFramePosition(startDelay*sampleRateOfFirstPlayer!)
                    }
                    
                    let playerStart = AVAudioTime(sampleTime: referenceSampleTime!, atRate: sampleRateOfFirstPlayer!)
                    playerNode.play(at: playerStart)
                }

  
            }

        } catch {
            fatalError("Unable to start audio engine: \(error).")
        }
        
        
        // The output buffer to which the engine renders the processed data.
        let buffer = AVAudioPCMBuffer(pcmFormat: audioEngine.manualRenderingFormat,
                                      frameCapacity: audioEngine.manualRenderingMaximumFrameCount)!

        
        // we ar erendering the output ionto this file
        var outputFile: AVAudioFile?
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        //let outputURL = documentsURL.appendingPathComponent("\(outputfileName).m4a")
        let outputURL = documentsURL.appendingPathComponent("\(outputfileName).caf")

        // Audio File settings
        let settings = [
            //AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: Int(outputSamplingRate),
            AVNumberOfChannelsKey: Int(2),
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]
        
        do {
            outputFile = try AVAudioFile(forWriting: outputURL, settings: settings)
        } catch {
            fatalError("Unable to open output audio file: \(error).")
        }
        
        
        // how many samples does the episode have?
        let mixerOutputSampleRate = audioEngine.mainMixerNode.outputFormat(forBus: 0).sampleRate
        let episodeDuration = calculateEpisodeDuration()
        let episodeSampleLength = AVAudioFramePosition(episodeDuration*mixerOutputSampleRate)
        
        while audioEngine.manualRenderingSampleTime < episodeSampleLength {
            do {
                let frameCount = episodeSampleLength - audioEngine.manualRenderingSampleTime
                let framesToRender = min(AVAudioFrameCount(frameCount), buffer.frameCapacity)
                
                let status = try audioEngine.renderOffline(framesToRender, to: buffer)
                
                switch status {
                    
                case .success:
                    // The data rendered successfully. Write it to the output file.
                    try outputFile?.write(from: buffer)
                    
                case .insufficientDataFromInputNode:
                    // Applicable only when using the input node as one of the sources.
                    break
                    
                case .cannotDoInCurrentContext:
                    // The engine couldn't render in the current render call.
                    // Retry in the next iteration.
                    break
                    
                case .error:
                    // An error occurred while rendering the audio.
                    fatalError("The manual rendering failed.")
                    
                @unknown default:
                    print("Unknown status case for audioEngine.renderOffline")
                }
            } catch {
                fatalError("The manual rendering failed: \(error).")
            }
        }
        // implicitely close the file
        // https://stackoverflow.com/questions/52184148/render-audio-file-offline-using-avaudioengine
        outputFile = nil
        
        // stop all audio players
        for segment in segments {
            for track in segment.tracks {
                track.playerNode.stop()
            }
        }
        
        // stop engine
        audioEngine.stop()
        
        // return URL
        return outputURL
        
    }
    
}