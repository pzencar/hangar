## Initial setup

- BL Heli -> Motor Timing: Auto, FreqLOW+HIGH: 24KHz for aggresive, 48kHz for more smoother
- ELRS preset + Default PID tune preset
- Blackbox GYRO_SCALED + 1.6 or 2 kHz
- Set PID and GYRO loop same freq ideally

## Filter tuning

- Full throttle ramp flight
- Turn off gyro lowpass 1
- Gyro lowpass 2 to max (or 850Hz+)
- But if gyro freq different from PID freq, you need to use gyro lowpass, potentially only 2 should be OK in this instance too
- Gyro RPM filter, set harmonics gains based on how strong is second and third harmonics e.g: `set rpm_filter_weights=100,40,70`
- Gyro RPM filter min frequency. From 1st harmonics. Find lowest point, give some headroom
- Tune headroom with fade (by distance from min freq set to start of noise: `set rpm_filter_fade_range_hz = 20` e.g 
- Dynamic notch. Find the strongest noise in the line. Increase Q factor if noise is very narrow. Leave 500 if its not narrow, the more narrow it is, increase it more. 1000 for very thin line
- Dynamic notch, set min and max freq of the strongest noise, put small margins
- Check notch count if obvious, should be 1 most of the time
- Disable DTerm lowpass 2
- DTerm lowpass 1 filter type BIQUAD, curve expo 7
- Tune DTerm lowpass 1 values with slider. I usually go by how far are RPM filter freqs from the default. If the frequencies are much higher, I increase this slider

## PID tuning

- `pisdum_limit and pidsum_limit yaw` set to 1000 
- Dynamic idle value 20-35 based on pitch (and presumably hover throttle). Higher pitch/lower idle throtthel, lower this number and vice versa
- FF, DMax, IGains sliders to 0
- MM flight (wiggle in angle). Increase Master multiplier by 0.2 until it starts sounding bad and motors are too hot
- Analyze step response in PIDToolbox -> Choose master multiplier for D Gains. Check for latency tradeoff with motor heat
- Tune PI slider. start from 0.8, increase until safe. Fly for each, to a bit of flips and wiggle in angle. Analyze in Step response and choose P&I slider value for great latency and overshoot and no undershoot characteristics characteristics
- If motors are getting too hot in this process, lower Master Multiplier
- Tune ITerm slider. For lighter drones might need more. (resistance to wind). If I term is too high, bounce backs on flips. Try to push up and check bounce backs on flips. Find ideal
- Set ITerm relax. Leave it normally. If drone is light and very racey aggresive, put it higher (20-35)
- Tune FF slider a and DMax slider. Do flips, set logviewer to roll/pitch and setpoints. Tune FF so that start of the flip (Sticks moving from center), the roll/pitch tracks the setpoint. Tune DMax for same thing, but at the end of the flip (sticks moving to the center) FF start from 1. DMax start from 0.8 (max 1.2)
