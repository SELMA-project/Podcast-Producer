//
//  AudioEpisode.swift
//  Podcast Producer
//
//  Created by Andy Giefer on 12.09.22.
//

import AVFoundation

struct AudioSegmentTrack {
    
    var url: URL
    var volume: Float
    var delay: Double
    var fadeIn: Double
    var fadeOut: Double
    
    var sourceFile: AVAudioFile
    
    var sampleRate: Double {
        return sourceFile.processingFormat.sampleRate
    }
    
    var startAudioTime: AVAudioTime {
        let numberOfSamplesEquivalentToDelay = Int64(floor(delay/sampleRate))
        let audioTime = AVAudioTime(sampleTime: numberOfSamplesEquivalentToDelay, atRate: sampleRate)
        return audioTime
    }
    
    /// Duration in seconds, including inital delay
    func calculateDuration() -> Double {
        let fileDuration = Double(sourceFile.length) / sampleRate
        return delay + fileDuration
    }
    
    init(url: URL, volume: Float?, delay: Double?, fadeIn: Double?, fadeOut: Double?) {
        self.url = url
        
        // set defauls
        self.volume = volume ?? 1.0
        self.delay = delay ?? 0.0
        self.fadeIn = fadeIn ?? 0.3
        self.fadeOut = fadeOut ?? 0.3
        
        // create AVAudioFile from URL
        do {
            sourceFile = try AVAudioFile(forReading: url)
            //format = sourceFile.processingFormat
        } catch {
            fatalError("Unable to load the source audio file: \(error.localizedDescription).")
        }
    }
    
    
}

struct AudioSegment {
    
    var tracks = [AudioSegmentTrack]()
    
    mutating func addTrack(url: URL, volume: Float?, delay: Double?, fadeIn: Double?, fadeOut: Double?){
        let newTrack = AudioSegmentTrack(url: url, volume: volume, delay: delay, fadeIn: fadeIn, fadeOut: fadeOut)
        tracks.append(newTrack)
    }
    
    func calculateDuration() -> Double {
        
        var segmentDuration = 0.0
        
        for track in tracks {
            let trackDuration = track.calculateDuration()
            segmentDuration = max(segmentDuration, trackDuration)
        }
        
        return segmentDuration
    }
}

struct AudioEpisode {
    
    /// Number of parallel audio tracks
    var outputSamplingRate: Double = 44100
    
    var audioEngine = AVAudioEngine()
    
    // stores sequence of segments
    var segments = [AudioSegment]()
    
    /// Creates a new audio segment and return its index
    mutating func addSegment() -> Int {
        let newSegment = AudioSegment()
        segments.append(newSegment)
        return segments.endIndex - 1
    }
    
    func addAudioTrack(toSegmentId segmentId: Int, url: URL, volume: Float?, delay: Double?, fadeIn: Double?, fadeOut: Double?) {
        
        if segmentId >= segments.endIndex {
            fatalError("Cannot add an audio track to non-existing segment with id \(segmentId)")
        }
        
        // retrieve affected segment
        var segment = segments[segmentId]
        
        // add track
        segment.addTrack(url: url, volume: volume, delay: delay, fadeIn: fadeIn, fadeOut: fadeOut)
        
        // duration
        let segmentDuration = segment.calculateDuration()
        print("The duration of segment \(segmentId) is: \(segmentDuration)")
    }
    
    /// Counts how many parallel tracks we need across all segments
//    func numberOfParallelTracks() -> Int {
//
//        // will contain result
//        var numberOfParallelTracks = 0
//
//        // go through each segment
//        for segment in segments {
//
//            // how many tracks does the segment have?
//            let numberOfSegmentTracks = segment.tracks.count
//
//            // we have at least as many parallel tracks
//            numberOfParallelTracks = max(numberOfParallelTracks, numberOfSegmentTracks)
//        }
//
//        return numberOfParallelTracks
//    }
    
    func calculateDuration() -> Double {
        
        var episodeDuration = 0.0
        
        for segment in segments {
            
            let segmentDuration = segment.calculateDuration()
            episodeDuration = max(episodeDuration, segmentDuration)
        }
 
        return episodeDuration
    }
    
    func render() -> URL {
        
        // temporary reference
        let referenceFileUrl = Bundle.main.url(forResource: "leilatest.caf", withExtension: nil)!
        let referenceAudioFile = try! AVAudioFile(forReading: referenceFileUrl)
        
        // we need as many player nodes as we have parallel tracks
        //let numberOfPlayers = numberOfParallelTracks()
                
        var startTimeOfCurrentSegment: Double = 0.0
        
        // staore all audio players here
        var playerNodes = [AVAudioPlayerNode]()
        
        // go throuch each segment
        for segment in segments {
            
            // go through each of the segment's tracks
            for track in segment.tracks {
                
                // create player
                let playerNode = AVAudioPlayerNode()
                
                // store it for later
                playerNodes.append(playerNode)
                
                // set volume
                playerNode.volume = track.volume
                
                // attach player to engine
                audioEngine.attach(playerNode)
                
                // connect to mixer
                audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: playerNode.outputFormat(forBus: 0))
                
                // schedule player's playback
                let playerStartTime = startTimeOfCurrentSegment + track.delay
                let startSampleTime = Int64(floor(playerStartTime / track.sampleRate))
                let startAudioTime = AVAudioTime(sampleTime: startSampleTime, atRate: track.sampleRate)
                playerNode.scheduleFile(track.sourceFile, at: startAudioTime)
                
                // calculate startTime of next Segment
                startTimeOfCurrentSegment += segment.calculateDuration()
            }
        }
        
        
        // setup engines for ma ual rendering
        do {
            // The maximum number of frames the engine renders in any single render call.
            let maxFrames: AVAudioFrameCount = 4096
            let outputFormat: AVAudioFormat = AVAudioFormat(standardFormatWithSampleRate: outputSamplingRate, channels: 1)!
            try audioEngine.enableManualRenderingMode(.offline, format: outputFormat, maximumFrameCount: maxFrames)
        } catch {
            fatalError("Enabling manual rendering mode failed: \(error).")
        }
        
        // start engines and players
        do {
            // start engine
            try audioEngine.start()
            
            // start all players
            for playerNode in playerNodes {
                playerNode.play()
            }

        } catch {
            fatalError("Unable to start audio engine: \(error).")
        }
        
        
        // The output buffer to which the engine renders the processed data.
        let buffer = AVAudioPCMBuffer(pcmFormat: audioEngine.manualRenderingFormat,
                                      frameCapacity: audioEngine.manualRenderingMaximumFrameCount)!


        
        var outputFile: AVAudioFile
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let outputURL = documentsURL.appendingPathComponent("output.caf")
            outputFile = try AVAudioFile(forWriting: outputURL, settings: referenceAudioFile.fileFormat.settings)
        } catch {
            fatalError("Unable to open output audio file: \(error).")
        }
        
        
        // how many samples does the episode have?
        let episodeDuration = calculateDuration()
        let episodeSampleLength = Int64(floor(episodeDuration/outputSamplingRate))
        
        while audioEngine.manualRenderingSampleTime < episodeSampleLength {
            do {
                let frameCount = episodeSampleLength - audioEngine.manualRenderingSampleTime
                let framesToRender = min(AVAudioFrameCount(frameCount), buffer.frameCapacity)
                
                let status = try audioEngine.renderOffline(framesToRender, to: buffer)

//                // control music volume based on time
//                let timeInSec = Double(audioEngine.manualRenderingSampleTime)/speechFormat.sampleRate
//                if Int(timeInSec) % 2 == 0 {
//                    musicPlayer.volume = 0.3
//                } else {
//                    musicPlayer.volume = 1.0
//                }
//                print("\(timeInSec)")
                
                switch status {
                    
                case .success:
                    // The data rendered successfully. Write it to the output file.
                    try outputFile.write(from: buffer)
                    
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
        
        // stop all audio players
        for playerNode in playerNodes {
            playerNode.stop()
        }
        
        // stop engine
        audioEngine.stop()
        
        // return URL
        return outputFile.url
        
    }
    
}
