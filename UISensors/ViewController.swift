//
//  ViewController.swift
//  UISensors
//
//  Created by rabbit on 2020/07/14.
//  Copyright © 2020 rabbit. All rights reserved.
//

import UIKit
import CoreLocation     // for Magnetic Heading, Location
import CoreMotion       // for Air Pressure, Acceleration, Gyro, Attitude
import AudioToolbox     // for Microphone

class ViewController: UIViewController {

    @IBOutlet weak var ambientLightValue: UILabel!

    @IBOutlet weak var proximityValue: UILabel!

    @IBOutlet weak var airPressureValue: UILabel!
    @IBOutlet weak var relativeAltitudeValue: UILabel!

    @IBOutlet weak var locationTime: UILabel!
    @IBOutlet weak var latitudeValue: UILabel!
    @IBOutlet weak var longitudeValue: UILabel!
    @IBOutlet weak var locationAccuracyValue: UILabel!
    @IBOutlet weak var altitudeValue: UILabel!
    @IBOutlet weak var speedValue: UILabel!

    @IBOutlet weak var magHeadingValue: UILabel!
    @IBOutlet weak var trueNorthValue: UILabel!
    @IBOutlet weak var magFluxDensity: UILabel!

    @IBOutlet weak var accelerationX: UILabel!
    @IBOutlet weak var accelerationY: UILabel!
    @IBOutlet weak var accelerationZ: UILabel!

    @IBOutlet weak var gyroX: UILabel!
    @IBOutlet weak var gyroY: UILabel!
    @IBOutlet weak var gyroZ: UILabel!

    @IBOutlet weak var attitudePitch: UILabel!
    @IBOutlet weak var attitudeRoll: UILabel!
    @IBOutlet weak var attitudeYaw: UILabel!

    @IBOutlet weak var micPeakValue: UILabel!
    @IBOutlet weak var micAvgValue: UILabel!
    @IBOutlet weak var micPeakValueDB: UILabel!
    @IBOutlet weak var micAvgValueDB: UILabel!

    var ambientLightSensor = false
    @IBOutlet weak var ambientLightButton: UIButton!
    @IBAction func ambientLightButtonAction(_ sender: Any) {
        ambientLightControl(!ambientLightSensor)
    }

    var proximitySensor = false
    @IBOutlet weak var proximityButton: UIButton!
    @IBAction func proximityButtonAction(_ sender: Any) {
        proximityControl(!proximitySensor)
    }

    var airPressureSensor = false
    @IBOutlet weak var airPressureButton: UIButton!
    @IBAction func airPressureButtonAction(_ sender: Any) {
        airPressureControl(!airPressureSensor)
    }
    var altimeter: CMAltimeter?

    var locationSensor = false
    @IBOutlet weak var locationButton: UIButton!
    @IBAction func locationButtonAction(_ sender: Any) {
        locationControl(!locationSensor)
    }
    var locationManagerForLoc: CLLocationManager?

    var magHeadingSensor = false
    @IBOutlet weak var magHeadButton: UIButton!
    @IBAction func magHeadButtonAction(_ sender: Any) {
        magHeadingControl(!magHeadingSensor)
    }
    var locationManagerForMagHead: CLLocationManager?

    var accelerationSensor = false
    @IBOutlet weak var accelerationButton: UIButton!
    @IBAction func accelerationButtonAction(_ sender: Any) {
        accelerationControl(!accelerationSensor)
    }
    var motionManager: CMMotionManager?

    var gyroSensor = false
    @IBOutlet weak var gyroButton: UIButton!
    @IBAction func gyroButtonAction(_ sender: Any) {
        gyroControl(!gyroSensor)
    }

    var attitudeSensor = false
    @IBOutlet weak var attitudeButton: UIButton!
    @IBAction func attitudeButtonAction(_ sender: Any) {
        attitudeControl(!attitudeSensor)
    }

    var microphoneSensor = false
    @IBOutlet weak var microphoneButton: UIButton!
    @IBAction func microphoneButtonAction(_ sender: Any) {
        microphoneControl(!microphoneSensor)
    }
    var audioQueue: AudioQueueRef!
    var audioTimer: Timer?
    var audioFormat = AudioStreamBasicDescription(
        mSampleRate: 44100.0,
        mFormatID: kAudioFormatLinearPCM,
        mFormatFlags: AudioFormatFlags(
            kLinearPCMFormatFlagIsBigEndian |
                kLinearPCMFormatFlagIsSignedInteger |
            kLinearPCMFormatFlagIsPacked
        ),
        mBytesPerPacket: 2,
        mFramesPerPacket: 1,
        mBytesPerFrame: 2,
        mChannelsPerFrame: 1,
        mBitsPerChannel: 16,
        mReserved: 0)

    // MARK: - Unit
    let Unit_degree = "\u{00B0}"    // °
    let Unit_hPa = " \u{3371}"      // hPa
    let Unit_ms = " \u{33A7}"       // m/s
    let Unit_ms2 = " \u{33A8}"      // m/s^2
    let Unit_rad = " \u{33AD}"      // rad
    let Unit_rads = " \u{33AE}"     // rad/s
    let Unit_dB = " \u{33C8}"       // dB

    // MARK: - Sign
    let Sign_PlusMinus = "\u{00B1}" // ±

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        becomeFirstResponder()

        ambientLightControl(false)
        proximityControl(false)
        airPressureControl(false)
        locationControl(false)
        magHeadingControl(false)
        accelerationControl(false)
        gyroControl(false)
        attitudeControl(false)
        microphoneControl(false)

    }

    //    override func viewWillAppear(_ animated: Bool) {
    //    }
    //
    //    override func viewWillLayoutSubviews() {
    //    }
    //
    //    override func viewDidLayoutSubviews() {
    //    }
    //
    //    override func viewDidAppear(_ animated: Bool) {
    //    }
    //
    //    override func viewWillDisappear(_ animated: Bool) {
    //    }
    //
    //    override func viewDidDisappear(_ animated: Bool) {
    //    }

    // MARK: - Shake motion

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return }
        // nop
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else { return }

        ambientLightControl(!ambientLightSensor)
        proximityControl(!proximitySensor)
        airPressureControl(!airPressureSensor)
        locationControl(!locationSensor)
        magHeadingControl(!magHeadingSensor)
        accelerationControl(!accelerationSensor)
        gyroControl(!gyroSensor)
        attitudeControl(!attitudeSensor)
        microphoneControl(!microphoneSensor)
    }

    // MARK: - Ambient Light Sensor

    func ambientLightControl(_ state: Bool) {
        if (state) {
            brightnessButtonState(true)
            brightnessDidChange()

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.brightnessDidChange),
                name: UIScreen.brightnessDidChangeNotification,
                object: nil
            )
        }
        else {
            NotificationCenter.default.removeObserver(
                self,
                name: UIScreen.brightnessDidChangeNotification,
                object: nil
            )

            brightnessButtonState(false)
        }
        ambientLightSensor = state
    }

    @objc func brightnessDidChange() {
        ambientLightValue.text = String(format: "%.3f", UIScreen.main.brightness)
    }

    func brightnessButtonState(_ state: Bool) {
        buttonON(ambientLightButton, state: state)
        ambientLightValue.text = ""
    }

    // MARK: - Proximity Sensor

    func proximityControl(_ state: Bool) {
        if (state) {
            UIDevice.current.isProximityMonitoringEnabled = true

            proximityButtonState(true)
            proximityStateDidChange()

            // NOTE : Display turns off when proximity sensor is covered.
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.proximityStateDidChange),
                name: UIDevice.proximityStateDidChangeNotification,
                object: nil
            )
        }
        else {
            UIDevice.current.isProximityMonitoringEnabled = false
            NotificationCenter.default.removeObserver(
                self,
                name: UIDevice.proximityStateDidChangeNotification,
                object: nil
            )

            proximityButtonState(false)
        }
        proximitySensor = state
    }

    @objc func proximityStateDidChange() {
        var state = "No"
        if (UIDevice.current.proximityState) {
            state = "Yes"
        }
        proximityValue.text = state
    }

    func proximityButtonState(_ state: Bool) {
        buttonON(proximityButton, state: state)
        proximityValue.text = ""
    }

    // MARK: - Air Pressure Sensor

    func airPressureControl(_ state: Bool) {
        if (altimeter == nil) {
            altimeter = CMAltimeter()
        }

        guard let _ = altimeter else { return }

        if (state) {
            airPressureButtonState(true)
            airPressureValue.numberOfLines = 0
            altimeter!.startRelativeAltitudeUpdates(to: OperationQueue.main) {
                (data, error) in
                self.airPressureValue.text = String(format: "%.1f" + self.Unit_hPa, Float(truncating: data!.pressure) * 10.0)
                self.relativeAltitudeValue.text = String(format: "rel.alt.= %+.1f m", Float(truncating: data!.relativeAltitude))
                // memo :
                //  1気圧(1 atm) = 1013.25 hPa
                //  取得開始時を 0 とした相対高度は data!.relativeAltitude で取得できる。（単位：m）
            }
        }
        else {
            altimeter!.stopRelativeAltitudeUpdates()
            airPressureButtonState(false)
        }
        airPressureSensor = state
    }

    func airPressureButtonState(_ state: Bool) {
        buttonON(airPressureButton, state: state)
        airPressureValue.text = ""
        relativeAltitudeValue.text = ""
    }

    // MARK: - Location

    // Note : You need to set "Privacy - Location When In Use Usage Description" on Info.plist.

    func locationControl(_ state: Bool) {
        // CLLocationManager.locationServicesEnabled() return true if location service is ON.
//        guard CLLocationManager.locationServicesEnabled() else {
//            locationButton.isEnabled = false
//            locationTime.text = ""
//            latitudeValue.text = ""
//            longitudeValue.text = ""
//            locationAccuracyValue.text = ""
//            altitudeValue.text = ""
//            speedValue.text = ""
//            return
//        }

        if (locationManagerForLoc == nil) {
            locationManagerForLoc = CLLocationManager()
            locationManagerForLoc!.delegate = self
        }

        if (state) {
            locationButtonState(true)

            locationManagerForLoc!.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            //            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManagerForLoc!.distanceFilter = 5                         // 5 m
            locationManagerForLoc!.pausesLocationUpdatesAutomatically = true
            locationManagerForLoc!.allowsBackgroundLocationUpdates = false

            locationManagerForLoc!.startUpdatingLocation()
        }
        else {
            locationManagerForLoc!.stopUpdatingLocation()
            locationButtonState(false)
        }
        locationSensor = state
    }

    func locationButtonState(_ state: Bool) {
        buttonON(locationButton, state: state)
        locationTime.text = ""
        latitudeValue.text = ""
        longitudeValue.text = ""
        locationAccuracyValue.text = ""
        altitudeValue.text = ""
        speedValue.text = ""
    }

    // MARK: - Magnetic Heading Sensor

    func magHeadingControl(_ state: Bool) {
        if (locationManagerForMagHead == nil) {
            locationManagerForMagHead = CLLocationManager()
            locationManagerForMagHead!.delegate = self

            //            locationManager!.headingFilter = kCLHeadingFilterNone
            locationManagerForMagHead!.headingFilter = 0.01   // notch = 0.01°
            locationManagerForMagHead!.headingOrientation = .portrait

            // for Location (Location updating)
            locationManagerForMagHead!.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            //            locationManagerForMagHead!.desiredAccuracy = kCLLocationAccuracyBest
            locationManagerForMagHead!.distanceFilter = 5                         // 5 m
            locationManagerForMagHead!.pausesLocationUpdatesAutomatically = true
            locationManagerForMagHead!.allowsBackgroundLocationUpdates = false

        }

        if (CLLocationManager.headingAvailable() && state) {
            magHeadButtonState(true)
            // Important
            // Property "trueHeding" contains a valid value only if location updates are also enabled for the corresponding location manager object.
            // Because the position of true north is different from the position of magnetic north on the Earth's surface, Core Location needs
            // the current location of the device to compute the value of this property.
            locationManagerForMagHead!.startUpdatingLocation()
            locationManagerForMagHead!.startUpdatingHeading()
        }
        else {
            locationManagerForMagHead!.stopUpdatingLocation()
            locationManagerForMagHead!.stopUpdatingHeading()
            magHeadButtonState(false)
        }
        magHeadingSensor = state
    }

    func magHeadButtonState(_ state: Bool) {
        buttonON(magHeadButton, state: state)
        magHeadingValue.text = ""
        trueNorthValue.text = ""
        magFluxDensity.text = ""
    }

    // MARK: - Acceleration

    func accelerationControl(_ state: Bool) {
        if (motionManager == nil) {
            motionManager = CMMotionManager()
        }

        guard motionManager!.isAccelerometerAvailable else {
            accelerationX.text = "Not supported."
            accelerationY.text = ""
            accelerationZ.text = ""
            return
        }

        if (state) {
            accelerationButtonState(true)
            motionManager!.accelerometerUpdateInterval = 0.2
            motionManager!.startAccelerometerUpdates(to: OperationQueue.current!) {
                (data, error) in
                guard let acceleration = data?.acceleration else { return }
                self.accelerationX.text = String(format: "X= %+.3f" + self.Unit_ms2, acceleration.x)
                self.accelerationY.text = String(format: "Y= %+.3f" + self.Unit_ms2, acceleration.y)
                self.accelerationZ.text = String(format: "Z= %+.3f" + self.Unit_ms2, acceleration.z)
            }

        }
        else {
            motionManager!.stopAccelerometerUpdates()
            accelerationButtonState(false)
        }
        accelerationSensor = state
    }

    func accelerationButtonState(_ state: Bool) {
        buttonON(accelerationButton, state: state)
        accelerationX.text = ""
        accelerationY.text = ""
        accelerationZ.text = ""
    }

    // MARK: - Gyro

    func gyroControl(_ state: Bool) {
        if (motionManager == nil) {
            motionManager = CMMotionManager()
        }

        guard motionManager!.isGyroAvailable else {
            gyroX.text = "Not supported."
            gyroY.text = ""
            gyroZ.text = ""
            return
        }

        if (state) {
            gyroButtonState(true)
            motionManager!.gyroUpdateInterval = 0.2
            motionManager!.startGyroUpdates(to: OperationQueue.current!) {
                (data, error) in
                guard let gyro = data?.rotationRate else { return }
                self.gyroX.text = String(format: "X= %+.3f" + self.Unit_rads, gyro.x)
                self.gyroY.text = String(format: "Y= %+.3f" + self.Unit_rads, gyro.y)
                self.gyroZ.text = String(format: "Z= %+.3f" + self.Unit_rads, gyro.z)
            }
        }
        else {
            motionManager!.stopGyroUpdates()
            gyroButtonState(false)
        }
        gyroSensor = state
    }

    func gyroButtonState(_ state: Bool) {
        if (state) {
            gyroButton.setTitleColor(.systemYellow, for: .normal)
            gyroButton.backgroundColor = .black
        }
        else {
            gyroButton.setTitleColor(.systemBlue, for: .normal)
            gyroButton.backgroundColor = .systemGray3
            gyroX.text = ""
            gyroY.text = ""
            gyroZ.text = ""
        }
    }

    // MARK: - Attitude

//    var originAttitude : CMAttitude?

    func attitudeControl(_ state: Bool) {
        if (motionManager == nil) {
            motionManager = CMMotionManager()
        }

        guard motionManager!.isDeviceMotionAvailable else {
            attitudePitch.text = ""
            attitudeRoll.text = "Not supported."
            attitudeYaw.text = ""
            return
        }

        if (state) {
            attitudeButtonState(true)
            motionManager!.deviceMotionUpdateInterval = 0.2
            motionManager!.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: OperationQueue.current!) {
                (data, error) in
                guard let attitude = data?.attitude else { return }

//                guard let _ = self.originAttitude else {
//                    self.originAttitude = attitude
//                    return
//                }

//                attitude.multiply(byInverseOf: self.originAttitude!)
                self.attitudePitch.text = String(format: "pitch= %+.3f" + self.Unit_rad, attitude.pitch)
                self.attitudeRoll.text = String(format: "roll = %+.3f" + self.Unit_rad, attitude.roll)
                self.attitudeYaw.text = String(format: "yaw  = %+.3f" + self.Unit_rad, attitude.yaw)
            }
        }
        else {
            motionManager!.stopDeviceMotionUpdates()
//            originAttitude = nil
            attitudeButtonState(false)
        }
        attitudeSensor = state
    }

    func attitudeButtonState(_ state: Bool) {
        if (state) {
            attitudeButton.setTitleColor(.systemYellow, for: .normal)
            attitudeButton.backgroundColor = .black
        }
        else {
            attitudeButton.setTitleColor(.systemBlue, for: .normal)
            attitudeButton.backgroundColor = .systemGray3
            attitudePitch.text = ""
            attitudeRoll.text = ""
            attitudeYaw.text = ""
        }
    }

    // MARK: - Microphone

    // Note : You need to set "Privacy - Microphone Usage Description" on Info.plist.

    func microphoneControl(_ state: Bool) {
        if (audioQueue == nil) {
            var queue: AudioQueueRef? = nil
            var error = noErr
            error = AudioQueueNewInput(
                &audioFormat,
                //                                        AudioQueueInputCallback,
                {
                    (inUserData, inAQ, inBuffer, inStartTime, inNumberPacketDescriptions, inPacketDescs) in
                    // nop
            },
                UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()),
                .none,
                .none,
                0,
                &queue
            )
            if (error == noErr) {
                audioQueue = queue
            }
            AudioQueueStart(self.audioQueue, nil)

            var enabledLevelMeter: UInt32 = 1
            AudioQueueSetProperty(
                self.audioQueue,
                kAudioQueueProperty_EnableLevelMetering,
                &enabledLevelMeter,
                UInt32(MemoryLayout<UInt32>.size)
            )
        }

        if (state) {
            microphoneButtonState(true)
            audioTimer = Timer.scheduledTimer(
                timeInterval: 0.5,
                target: self,
                selector: #selector(self.detectVolume),
                userInfo: nil,
                repeats: true
            )
            audioTimer!.fire()
        }
        else {
            audioTimer?.invalidate()
            microphoneButtonState(false)
        }
        microphoneSensor = state
    }

    @objc func detectVolume(timer: Timer) {
        // Get level
        var levelMeter = AudioQueueLevelMeterState()
        var propertySize = UInt32(MemoryLayout<AudioQueueLevelMeterState>.size)

        AudioQueueGetProperty(
            self.audioQueue,
            kAudioQueueProperty_CurrentLevelMeter,
            &levelMeter,
            &propertySize)
        micPeakValue.text = String(format: "peak= %.3f", levelMeter.mPeakPower)
        micAvgValue.text = String(format: "avg.= %.3f", levelMeter.mAveragePower)

        AudioQueueGetProperty(
            self.audioQueue,
            kAudioQueueProperty_CurrentLevelMeterDB,
            &levelMeter,
            &propertySize)
        micPeakValueDB.text = String(format: "peak= %.3f" + self.Unit_dB, levelMeter.mPeakPower)
        micAvgValueDB.text = String(format: "avg.= %.3f" + self.Unit_dB, levelMeter.mAveragePower)
    }

    func microphoneButtonState(_ state: Bool) {
        buttonON(microphoneButton, state: state)
        micPeakValue.text = ""
        micAvgValue.text = ""
        micPeakValueDB.text = ""
        micAvgValueDB.text = ""
    }

    // MARK: - common

    func buttonON(_ button: UIButton, state: Bool) {
        if (state) {
            button.setTitleColor(.systemYellow, for: .normal)
            button.backgroundColor = .black
        }
        else {
            button.setTitleColor(.systemBlue, for: .normal)
            button.backgroundColor = .systemGray3
        }
    }

}


// MARK: Microphone

//private func AudioQueueInputCallback(
//    _ inUserData: UnsafeMutableRawPointer?,
//    inAQ: AudioQueueRef,
//    inBuffer: AudioQueueBufferRef,
//    inStartTime: UnsafePointer<AudioTimeStamp>,
//    inNumberPacketDescriptions: UInt32,
//    inPacketDescs: UnsafePointer<AudioStreamPacketDescription>?) {
//    // nop
//}



extension ViewController: CLLocationManagerDelegate {

    //    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    //        let status = CLLocationManager.authorizationStatus()
    //        switch status {
    //            case .authorizedAlways: return
    //            case .authorizedWhenInUse: manager.requestAlwaysAuthorization()
    //            case .restricted, .denied: return
    //            case .notDetermined: manager.requestWhenInUseAuthorization()
    //            default: fatalError()
    //        }
    //    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .authorizedAlways: return
            case .authorizedWhenInUse: manager.requestAlwaysAuthorization()
            case .restricted, .denied: return
            case .notDetermined: manager.requestWhenInUseAuthorization()
            default: fatalError()
        }
    }

    // MARK: Location

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        guard locationSensor else { return }

        let formatter = DateFormatter()
        //        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        formatter.dateStyle = .short
        formatter.timeStyle = .long
        locationTime.text = formatter.string(from: location.timestamp)

        // latitude / longitude
        if (location.horizontalAccuracy >= 0.0) {
            latitudeValue.text = String(format: "%.6f" + Unit_degree + "N", location.coordinate.latitude)
            longitudeValue.text = String(format: "%.6f" + Unit_degree + "E", location.coordinate.longitude)
            locationAccuracyValue.text = String(format: "r= %.1f m", location.horizontalAccuracy)
        }
        else {
            latitudeValue.text = "?" + Unit_degree + "N"
            longitudeValue.text = "?" + Unit_degree + "E"
            locationAccuracyValue.text = "? m"
        }

        // altitude
        if (location.verticalAccuracy >= 0.0) {
            altitudeValue.text = String(format: "alt= %.1f " + Sign_PlusMinus + "%.1f m", location.altitude, location.verticalAccuracy)
        }
        else {
            altitudeValue.text = "? m"
        }

        // speed
        if (location.speedAccuracy >= 0.0) {
            speedValue.text = String(format: "%.1f " + Sign_PlusMinus + "%.1f" + Unit_ms, location.speed, location.speedAccuracy)
        }
        else {
            speedValue.text = "?" + Unit_ms
        }
    }

    // MARK: Magnetic Heading Sensor

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {

        // magnetic North
        if (newHeading.headingAccuracy >= 0.0) {
            var mn = newHeading.magneticHeading
            mn = mn <= 180.0 ? -1.0 * mn : 360.0 - mn
            magHeadingValue.text = String(format: "M.N.= %.1f " + Sign_PlusMinus + "%.1f" + Unit_degree,
                                          mn,
                                          newHeading.headingAccuracy)   // M.N. : Magnetic North
        }
        else {
            magHeadingValue.text = "M.N.= ?"
        }

        // true North
        if (newHeading.trueHeading >= 0.0) {
            var tn = newHeading.trueHeading
            tn = tn <= 180.0 ? -1.0 * tn : 360.0 - tn
            trueNorthValue.text = String(format: "T.N.= %.1f" + Unit_degree, tn)    // T.N. : True North
        }
        else {
            trueNorthValue.text = "T.N.= ?"
        }

        // magnetic flux density
        let t = sqrt(newHeading.x * newHeading.x + newHeading.y * newHeading.y + newHeading.z * newHeading.z)
        magFluxDensity.textColor = .label
        if ((t < 24.0) || (66.0 < t)) {         // latitude 0 - 90
            magFluxDensity.textColor = .systemRed
        }
        else if ((t < 44.0) || (51.0 < t)) {    // okinawa - hokkaido
            magFluxDensity.textColor = .systemOrange
        }
        magFluxDensity.text = String(format: "Dens.= %.3f uT", t)
    }



    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let cle = error as! CLError

        if (locationSensor) {
            switch (cle.code) {
                case .denied:
                    locationTime.text =  ""
                    latitudeValue.text = "Location service"
                    longitudeValue.text = "are disabled."
                    locationAccuracyValue.text = ""
                    altitudeValue.text = ""

                case .locationUnknown:
                    let formatter = DateFormatter()
                    formatter.dateStyle = .short
                    formatter.timeStyle = .long
                    locationTime.text = formatter.string(from: Date())
                    latitudeValue.text = "Failure"
                    longitudeValue.text = ""
                    locationAccuracyValue.text = ""
                    altitudeValue.text = ""

                default: break
            }
        }

        if (magHeadingSensor) {
            switch (cle.code) {
                case .denied:
                    trueNorthValue.text = "Loc-svc : disabled"
                case .headingFailure:
                    magHeadingValue.text = "M.N.= Failure"
                    trueNorthValue.text = ""
                    magFluxDensity.text = ""

                default: break
            }
        }

    }

}

