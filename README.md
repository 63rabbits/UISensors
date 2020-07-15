# UISensors

| | |
|:-------------------------:|:-------------------------:|
|<img src=https://github.com/63rabbits/UISensors/blob/master/Sensors-0001.png width="300">|<img src=https://github.com/63rabbits/UISensors/blob/master/Sensors-0002.png width="300">|

The information is obtained from the following sensors on iOS Device.

次のデバイス・センサーから情報を取得する。

### Ambient Light / 環境光

Get the ambient light intensity of the device. (intensity = 0.0 - 1.0)

周辺光の強度を取得する。強度は0.0 - 1.0の範囲。

### Proximity / 近接

Get the proximity status of an object. (true/false)

物体の近接状況を取得する。近接している場合にTrue。

### Air Pressure / 気圧

Get the air pressure (hPa) and relative altitude (m).

気圧(hPa)と相対高度(m)を取得する。

高度は計測開始時を0mとした相対値である。

### Location / 測位

Get the current location (measurement time, latitude, longitude), altitude (m) and moving speed (m/s).

現在地（計測時刻、経緯度）、高度(m)および移動速度(m/s)を取得する。

### Compass / 磁気

Obtain the angle (in degrees) from the magnetic north/true north to the device head and the magnetic flux density (uT) in the x/y/z directions.

磁北／真北からデバイス・ヘッドへの角度（度数法）とx/y/z方向への磁束密度（uT）を取得する。

### Acceleration / 加速度

Get the acceleration of the device (x/y/z-directions) can be obtained. (m/s^2)

デバイスのx/y/z方向への加速度（m/s^2）を取得する。

### Gyro / ジャイロ

Get the angular velocity of the device (pitch, roll, yaw). (rad/s)

デバイスのピッチ、ロール、ヨーの角速度(rad/s）を取得する。

### Microphone / マイク

Get the sound intensity with RMS power (peak and average). (0.0 - 1.0 or dB)(RMS : root mean square)

音の強度を取得する。強度は0.0 - 1.0の範囲、または、dB。

### Shake Motion / シェイク・モーション

Detects shake motion and switches the button state.

シェイク・モーションを検出し、ボタンの状態を反転する。

