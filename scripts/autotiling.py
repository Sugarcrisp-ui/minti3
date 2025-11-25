#!/usr/bin/env python3
"""
autotiling.py – Smart split direction based on golden ratio
2025-final: type hints, constants, tiny perf wins
"""

from __future__ import annotations

import signal
import sys
from argparse import ArgumentParser
from functools import partial
from typing import Any

from i3ipc import Connection, Event

GOLDEN_RATIO = 1.618_033_988_749_894_848_204_586_834_365_638_117_720_309_179_805_762_862_135_448_622_705_260_462_818_902_449_707_207_204_189_391_137_484_754_088_075_386_891_752_126_633_862_223_536_931_793_180_060_766_726_354_433_389_086_595_939_582_905_638_322_661_319_928_290_267_880_675_208_766_892_501_711_696_207_032_221_043_216_269_548_626_296_313_614_438_149_758_701_220_874_903_883_198_594_448_034_654_889_077_872_793_830_081_647_844_609_550_582_231_725_359_408_128_481_117_450_284_102_701_938_521_105_559_644_622_948_954_930_381_964_428_810_975_665_933_446_128_475_648_233_786_783_165_271_201_909_145_648_566_923_460_348_610_454_326_648_213_393_607_260_249_141_273_724_587_006_606_315_588_174_881_520_920_962_829_254_091_715_364_367_892_590_360_011_330_530_548_820_466_521_384_146_951_941_511_609_433_057_270_365_759_591_953_092_186_117_381_932_611_793_105_118_548_074_462_379_962_749_567_351_885_752_724_891_227_938_183_011_949_12  # φ


def _should_split_vertically(width: int, height: int) -> bool:
    """Return True if window is taller than wide × golden ratio."""
    return height > width / GOLDEN_RATIO


def switch_splitting(
    i3: Connection,
    event: Any,  # noqa: ARG001 (event unused but required by i3ipc)
    last_id: list[int | None],
    debug: bool = False,
) -> None:
    """Switch parent container layout based on focused window aspect ratio."""
    focused = i3.get_tree().find_focused()
    if (
        not focused
        or focused.type != "con"
        or not focused.parent
        or focused.id == last_id[0]
    ):
        return

    target = "splitv" if _should_split_vertically(focused.rect.width, focused.rect.height) else "splith"

    if target != focused.parent.layout:
        if debug:
            print(f"autotiling: {focused.rect.width}x{focused.rect.height} → {target}", file=sys.stderr)
        i3.command(target)

    last_id[0] = focused.id


def main() -> None:
    parser = ArgumentParser(description="Smart autotiling for i3/sway using the golden ratio")
    parser.add_argument("-d", "--debug", action="store_true", help="Print debug info")
    args = parser.parse_args()

    i3 = Connection()
    last_id: list[int | None] = [None]

    handler = partial(switch_splitting, last_id=last_id, debug=args.debug)
    i3.on(Event.WINDOW_FOCUS, handler)

    for sig in (signal.SIGINT, signal.SIGTERM):
        signal.signal(sig, lambda s, f: i3.main_quit())

    print("autotiling.py started (golden ratio mode)", file=sys.stderr)
    i3.main()


if __name__ == "__main__":
    main()
