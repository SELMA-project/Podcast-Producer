//
//  AudioEpisode.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 12.09.22.
//

import AVFoundation

/// Represents one audio track inside a segment
struct AudioSegmentTrack {
    
    /// the track's identifier
    var id: Int
    
    /// the URL of the audio file which the track plays
    var url: URL
    
    /// the track's volume
    var volume: Float
    
    /// initial playback delay in seconds
    var relativeStart: Double
    
    /// the fade-in duration in seconds
    var fadeIn: Double
    
    /// the fade-out duration in seconds
    var fadeOut: Double
    
    /// the track'S player node
    var playerNode: AVAudioPlayerNode
    
    /// sample rate in samples per second
    var sampleRate: Double {
        return sourceFile.processingFormat.sampleRate
    }
    
    /// the number of audio samples of the track's audio file
    var numberOfAudioSamples: AVAudioFramePosition {
        return sourceFile.length
    }
    
    /// the audio file's processing format
    var processingFormat: AVAudioFormat {
        return sourceFile.processingFormat
    }
    
    /// the  AVAudioTime relative to the track's segment start at which the pplayer starts playing (cooresponds to delay)
    var startAudioTime: AVAudioTime {
        let numberOfSamplesEquivalentToRelativeStart = AVAudioFramePosition(relativeStart*sampleRate)
        let audioTime = AVAudioTime(sampleTime: numberOfSamplesEquivalentToRelativeStart, atRate: sampleRate)
        return audioTime
    }

    /// the sample buffer
    var inputBuffer: AVAudioPCMBuffer
    
    /// stores the audio file
    private var sourceFile: AVAudioFile
    
    /// duration in seconds, including delay introduced through relativeStart
    func calculateDurationIncludingRelativeStart() -> Double {
        let fileDuration = Double(numberOfAudioSamples) / sampleRate
        return relativeStart + fileDuration
    }
    
    init(id: Int, url: URL, volume: Float, relativeStart: Double, fadeIn: Double, fadeOut: Double) {

        // store id and url
        self.id = id
        self.url = url
        
        // set defaults
        self.volume = volume
        self.relativeStart = relativeStart
        self.fadeIn = fadeIn
        self.fadeOut = fadeOut
        
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
        playerNode.volume = volume
    }
    
    
}

/// Represents an Audio segment
struct AudioSegment {
    
    var id: Int
    var tracks = [AudioSegmentTrack]()
    
    /// Add a new track to the AudioSegment
    mutating func addTrack(url: URL, volume: Float, relativeStart: Double, fadeIn: Double, fadeOut: Double) {
        
        // the tracks's id is the next index in the array
        let trackId = tracks.endIndex
        
        let newTrack = AudioSegmentTrack(id: trackId, url: url, volume: volume, relativeStart: relativeStart, fadeIn: fadeIn, fadeOut: fadeOut)
        tracks.append(newTrack)
    }
    
    /// The duration of the enitre segment including all audio tracks
    func calculateSegmentDuration() -> Double {
        
        var segmentDuration = 0.0
        
        for track in tracks {
            let trackDuration = track.calculateDurationIncludingRelativeStart()
            segmentDuration = max(segmentDuration, trackDuration)
        }
        
        return segmentDuration
    }
}

/// Represents the entire Audio Episode
struct AudioEpisode {
    
    /// Number of parallel audio tracks
    var outputSamplingRate: Double = 48000
    
    /// The Audio Engine
    private var audioEngine = AVAudioEngine()
    
    // Stores sequence of segments
    private var segments = [AudioSegment]()
    
    /// Creates a new audio segment and return its index
    mutating func addSegment() -> Int {
        
        // the segment's id is the next index in the array
        let segmentId = segments.endIndex
        
        // create segment
        let newSegment = AudioSegment(id: segmentId)
        segments.append(newSegment)
        
        return segmentId
    }
    
    /// Adds an audio track to a segment with the given ID
    mutating func addAudioTrack(toSegmentId segmentId: Int, url: URL, delay: Double = 0.0, volume: Float = 1.0, fadeIn: Double = 0.1, fadeOut: Double = 0.1, appendToPreviousTrack: Bool) {
        
        if segmentId >= segments.endIndex {
            fatalError("Cannot add an audio track to non-existing segment with id \(segmentId)")
        }
        
        // retrieve affected segment
        var segment = segments[segmentId]
        
        // the track should at least be delayed by <delay>
        var relativeStart = delay

        // if we want to append the track to the end of of the previous track, determine its end time
        var previousTrackEndTime = 0.0
        if appendToPreviousTrack {
            // calculate when previous tracks ends
            if let previousTrack = segment.tracks.last {
                previousTrackEndTime = previousTrack.calculateDurationIncludingRelativeStart()
            }
        }
        
        // add segment's duration to the relative start
        relativeStart += previousTrackEndTime
        
        // add track
        segment.addTrack(url: url, volume: volume, relativeStart: relativeStart, fadeIn: fadeIn, fadeOut: fadeOut)
        
        // replace old segment with updated segment
        segments[segmentId] = segment
        
        // debug duration
        // let segmentDuration = segment.calculateSegmentDuration()
        // print("The duration of segment \(segmentId) is: \(segmentDuration)")
    }
    
    /// The absolute start time of the audio track with respect to the Episode's start
    func startTimeOfTrack(withId trackId: Int, inSegmentWithId segmentId: Int) -> AVAudioTime {
        
        // sum up the duration of all previous Segments -> start of segment with <segmentId>
        var segmentStartInSeconds = 0.0
        for index in 0..<segmentId {
            segmentStartInSeconds += segments[index].calculateSegmentDuration()
        }
        
        // add relativeStart
        let relevantSegment = segments[segmentId]
        let relevantTrack = relevantSegment.tracks[trackId]
        let trackDelay = relevantTrack.relativeStart
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
    
    /// The duration in seconds of the entire episode
    func calculateEpisodeDuration() -> Double {
        
        var episodeDuration = 0.0
        
        for segment in segments {
            
            let segmentDuration = segment.calculateSegmentDuration()
            episodeDuration = max(episodeDuration, segmentDuration)
        }
 
        return episodeDuration
    }
    
    /// Renders the entire episode
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
        
        // the output audio format to use
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

        
        // we are rendering the output into this file
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
        
        // opene output file for writing
        do {
            outputFile = try AVAudioFile(forWriting: outputURL, settings: settings)
        } catch {
            fatalError("Unable to open output audio file: \(error).")
        }
        
        // how many samples does the episode have?
        let mixerOutputSampleRate = audioEngine.mainMixerNode.outputFormat(forBus: 0).sampleRate
        let episodeDuration = calculateEpisodeDuration()
        let episodeSampleLength = AVAudioFramePosition(episodeDuration * mixerOutputSampleRate)
        
        // render audio chunks
        while audioEngine.manualRenderingSampleTime < episodeSampleLength {
            do {
                
                // how many frames do we render this time?
                let frameCount = episodeSampleLength - audioEngine.manualRenderingSampleTime
                let framesToRender = min(AVAudioFrameCount(frameCount), buffer.frameCapacity)
                
                // get status and act upon it
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
