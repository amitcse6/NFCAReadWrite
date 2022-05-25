//
//  ViewController.swift
//  NFCAReadWrite
//
//  Created by AMIT on 5/25/22.
//

import UIKit
import CoreNFC

class ViewController: UIViewController {
    
    @IBOutlet weak var messageLabel: UILabel!
    

    let read_session_status: [UInt8] = [0x3A, 0xEC, 0xED]
    
    let readCommandData : [UInt8] = [0x3A, 0xF0, 0xFF] //fast read
    
    var writeCommand: [UInt8] = [0xA6, 0xF0, 0xFF] //A6: fast write, f0:start address, ff:end address
    
    let CONNECT: [UInt8] = [0x00, 0x00]
    let EMPTY: [UInt8] = []
    let RESET_DATA: [UInt8] = [0x00, 0x0c, 0x00, 0x10, 0x02]
    let READ_DATA: [UInt8] =  [0x00, 0x0c, 0x00, 0x10, 0x03]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func scanButtonClicked(_ sender: Any) {
        scan()
    }
    
    func scan() {
        // Look for ISO 14443 and ISO 15693 tags
        let session = NFCTagReaderSession(pollingOption: [.iso14443, .iso15693], delegate: self)
        session?.begin()
    }
}

extension ViewController: NFCTagReaderSessionDelegate {
    // Error handling again
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) { }
    
    // Additionally there's a function that's called when the session begins
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) { }
    
    // Note that an NFCTag array is passed into this function, not a [NFCNDEFMessage]
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        connect(session, didDetect: tags)
    }
}
extension ViewController {
    func connect(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let tag = tags.first else { return }
        session.connect(to: tag) { (error: Error?) in
            if error != nil {
                session.invalidate(errorMessage: "Connection error. Please try again.")
                return
            }
            print("Connected to tag!")
            switch tag {
            case .miFare(let discoveredTag):
                print("Got a MiFare tag!", discoveredTag.identifier, discoveredTag.mifareFamily)
                //[0x3A, 0xEC, 0xED] This command working fine
                self.sendRequest(discoveredTag, [0xA6, 0xF0, 0xFF], [0x00, 0x0c, 0x00, 0x10, 0x03]) { response in
                    print("response: \(response?.value ?? -1)")
                }
                break
            case .feliCa(let discoveredTag):
                print("Got a FeliCa tag!", discoveredTag.currentSystemCode, discoveredTag.currentIDm)
                break
            case .iso15693(let discoveredTag):
                print("Got a ISO 15693 tag!", discoveredTag.icManufacturerCode, discoveredTag.icSerialNumber, discoveredTag.identifier)
                break
            case .iso7816(let discoveredTag):
                print("Got a ISO 7816 tag!", discoveredTag.initialSelectedAID, discoveredTag.identifier)
                break
            @unknown default:
                session.invalidate(errorMessage: "Unsupported tag!")
                break
            }
        }
    }
    
    public func sendRequest(_ tag: NFCMiFareTag, _ command: [UInt8], _ payload: [UInt8]?,  completion: @escaping((NfcConnectResponse?) -> Void)) {
        var dataPacket = Data(bytes: command, count: command.count)
        if let payload = payload {
            let _dataPacket = Data(bytes: payload, count: payload.count)
            dataPacket.append(contentsOf: _dataPacket)
        }
        tag.sendMiFareCommand(commandPacket: dataPacket) { (cmdResp, err) in
            if let cmdErr = err {
                print("Received error while sending command!", cmdErr)
                completion(nil)
                return
            }
            
            print(cmdResp, "READ Response")
            let bytes: [UInt8] = [UInt8](cmdResp)
            print(bytes, bytes.count , "READ ByteArray")
            
            
            let inst = NfcResponseFactory()
            let nfcResponse = inst.getNfcResponse(bytes)
            print("value: \(nfcResponse.value)")
            completion(nfcResponse)
        }
    }
}
