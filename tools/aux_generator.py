from enum import IntEnum
from dataclasses import dataclass

class ModeMap(IntEnum):
    ARM = 0
    ANGLE = 1
    HORIZON = 2
    ALT_HOLD= 3
    ANTI_GRAVITY = 4
    MAG = 5
    HEADFREE = 6
    HEADADJ = 7
    CAMSTAB = 8
    POS_HOLD = 11
    PASSTHRU = 12
    BEEPERON = 13
    LEDLOW = 15
    CALIB = 17
    OSD = 19
    TELEMETRY = 20
    SERVO1 = 23
    SERVO2 = 24
    SERVO3 = 25
    BLACKBOX = 26
    FAILSAFE = 27
    AIRMODE = 28
    _3D = 29
    FPV_ANGLE_MIX = 30
    BLACKBOX_ERASE = 31
    CAMERA_CONTROL_1 = 32
    CAMERA_CONTROL_2 = 33
    CAMERA_CONTROL_3 = 34
    FLIP_OVER_AFTER_CRASH = 35
    BOXPREARM = 36
    BEEP_GPS_SATELLITE_COUNT = 37
    VTX_PIT_MODE = 39
    USER1 = 40
    USER2 = 41
    USER3 = 42
    USER4 = 43
    PID_AUDIO = 44
    PARALYZE = 45
    GPS_RESCUE = 46
    ACRO_TRAINER = 47
    DISABLE_VTX_CONTROL = 48
    LAUNCH_CONTROL = 49
    MSP_OVERRIDE = 50
    STICK_COMMANDS_DISABLE = 51
    BEEPER_MUTE = 52
    READY = 53
    LAP_TIMER_RESET = 54

MODE_LABEL = {
    0: 'ARM',
    1: 'ANGLE',
    2: 'HORIZON',
    3: 'ALT_HOLD',
    4: 'ANTI_GRAVITY',
    5: 'MAG',
    6: 'HEADFREE',
    7: 'HEADADJ',
    8: 'CAMSTAB',
    11: 'POS_HOLD',
    12: 'PASSTHRU',
    13: 'BEEPERON',
    15: 'LEDLOW',
    17: 'CALIB',
    19: 'OSD',
    20: 'TELEMETRY',
    23: 'SERVO1',
    24: 'SERVO2',
    25: 'SERVO3',
    26: 'BLACKBOX',
    27: 'FAILSAFE',
    28: 'AIRMODE',
    29: '_3D',
    30: 'FPV_ANGLE_MIX',
    31: 'BLACKBOX_ERASE',
    32: 'CAMERA_CONTROL_1',
    33: 'CAMERA_CONTROL_2',
    34: 'CAMERA_CONTROL_3',
    35: 'FLIP_OVER_AFTER_CRASH',
    36: 'BOXPREARM',
    37: 'BEEP_GPS_SATELLITE_COUNT',
    39: 'VTX_PIT_MODE',
    40: 'USER1',
    41: 'USER2',
    42: 'USER3',
    43: 'USER4',
    44: 'PID_AUDIO',
    45: 'PARALYZE',
    46: 'GPS_RESCUE',
    47: 'ACRO_TRAINER',
    48: 'DISABLE_VTX_CONTROL',
    49: 'LAUNCH_CONTROL',
    50: 'MSP_OVERRIDE',
    51: 'STICK_COMMANDS_DISABLE',
    52: 'BEEPER_MUTE',
    53: 'READY',
    54: 'LAP_TIMER_RESET',
}


@dataclass
class AuxMode:
    mode: ModeMap
    aux: int
    bit: int = 0
    bit_width: int = 1
    min_: int = 1000
    max_: int = 2000

def get_bit_ranges(min_: int, max_: int, bit_width: int) -> dict[int, list[tuple[int, int]]]:
    num_states = 1 << bit_width  # 2^6 = 64
    span = max_ - min_
    window_size = span / num_states

    bit_ranges = {i: [] for i in range(bit_width)}
    
    for s in range(num_states):
        start_range = min_ + (s * window_size)
        end_range = min_ + ((s + 1) * window_size)

        if start_range == min_:
            start_range -= 50

        if end_range == max_:
            end_range += 50
        
        for bit in range(bit_width):
            if (s >> bit) & 1:
                # Merge consecutive ranges to keep the list clean
                if bit_ranges[bit] and abs(bit_ranges[bit][-1][1] - start_range) < 1e-5:
                    bit_ranges[bit][-1] = (bit_ranges[bit][-1][0], end_range)
                else:
                    bit_ranges[bit].append((start_range, end_range))
                    
    return bit_ranges

def evaluate_modes(modes) -> str:
    MAX_IDX = 18
    aux = ''

    idx = 0

    for mode in modes:
        ranges = get_bit_ranges(mode.min_, mode.max_, mode.bit_width)

        for range_ in ranges[mode.bit]:
            aux += f'aux {idx} {int(mode.mode)} {mode.aux} {range_[0]} {range_[1]}  # {MODE_LABEL[mode.mode]}\n'
            idx += 1

    if idx > MAX_IDX:
        raise RuntimeError(f'Number of indexes needed is higher than betaflight maximum ({MAX_IDX})')
    else:
        for i in range(idx, MAX_IDX + 1):
            aux += f'aux {i} 0 0 900 900\n'

    return aux

if __name__ == '__main__':
    MODES = [
        AuxMode(
            mode=ModeMap.ARM,
            aux = 0,
        ),
        AuxMode(
            mode=ModeMap.BOXPREARM,
            aux = 1,
            bit = 2,
            bit_width = 3,
        ),
        AuxMode(
            mode=ModeMap.GPS_RESCUE,
            aux = 1,
            bit = 1,
            bit_width = 3,
        ),
        AuxMode(
            mode=ModeMap.AIRMODE,
            aux = 2,
            bit = 2,
            bit_width = 3,
        ),
        AuxMode(
            mode=ModeMap.ANGLE,
            aux = 2,
            bit = 1,
            bit_width = 3,
        ),
        AuxMode(
            mode=ModeMap.ALT_HOLD,
            aux = 2,
            bit = 0,
            bit_width = 3,
        ),
        AuxMode(
            mode=ModeMap.POS_HOLD,
            aux = 2,
            bit = 0,
            bit_width = 3,
        ),
    ]
    aux = evaluate_modes(MODES)
    print(aux)
