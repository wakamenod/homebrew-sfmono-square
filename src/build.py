# -*- coding:utf-8 -*-
import sys

from concurrent.futures import ProcessPoolExecutor, as_completed
import font_patcher
import shippori_mincho
import gofont_mono
import sfmono_square
import fonttools

SHIPPORI_MINCHO = [["ShipporiMincho-Regular.ttf"], ["ShipporiMincho-Bold.ttf"]]
SHIPPORI_MINCHO_MODIFIED = [["modified-ShipporiMincho-regular.ttf"], ["modified-ShipporiMincho-bold.ttf"]]
GOFONT_MONO = [
    ["Go-Mono.ttf"],
    ["Go-Mono-Bold.ttf"],
    ["Go-Mono-Italic.ttf"],
    ["Go-Mono-Bold-Italic.ttf"],
]
GOFONT_MONO_SHIPPORI_MINCHO = [
    ["GoMono-1x2-Go-Mono.ttf", "modified-ShipporiMincho-Regular.ttf"],
    ["GoMono-1x2-Bold.ttf", "modified-ShipporiMincho-Bold.ttf"],
    ["GoMono-1x2-Italic.ttf", "modified-ShipporiMincho-oblique.ttf"],
    ["GoMono-1x2-Bold-Italic.ttf", "modified-ShipporiMincho-bold-oblique.ttf"],
]
GOFONT_MONO_SQUARE = [
    ["GoMonoSquare-Mono.otf", "Regular"],
    ["GoMonoSquare-Bold.otf", "Bold"],
    ["GoMonoSquare-Italic.otf", "RegularItalic"],
    ["GoMonoSquare-Bold-Italic.otf", "BoldItalic"],
]
OUT_DIR = "build"

def build(version):
    print("---- modifying Shippori Mincho ----")
    if concurrent_execute(shippori_mincho.modify, SHIPPORI_MINCHO):
        return 1
    print("---- making oblique version of Shippori Mincho ----")
    if concurrent_execute(shippori_mincho.oblique, SHIPPORI_MINCHO_MODIFIED):
        return 1
    print("---- modifying Go Mono ----")
    if concurrent_execute(gofont_mono.modify, GOFONT_MONO):
        return 1
    print("---- generate Go Mono Square ----")
    args = [a + [version] for a in GOFONT_MONO_SHIPPORI_MINCHO]
    if concurrent_execute(sfmono_square.generate, args):
        return 1
    print("---- adding nerd-fonts glyphs ----")
    args = [[a[0], OUT_DIR] for a in GOFONT_MONO_SQUARE]
    if concurrent_execute(font_patcher.patch, args):
        return 1
    print("---- overwriting table with fonttools")
    args = [[f"{OUT_DIR}/{a[0]}", a[1]] for a in GOFONT_MONO_SQUARE]
    if concurrent_execute(fonttools.update, args):
        return 1
    return 0


def concurrent_execute(func, args):
    executor = ProcessPoolExecutor()
    futures = [executor.submit(func, *a) for a in args]
    return 1 if any([r.result() for r in as_completed(futures)]) else 0
