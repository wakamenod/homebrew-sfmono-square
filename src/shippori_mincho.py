# -*- coding:utf-8 -*-
from os import getenv
from os.path import splitext

import fontforge
import psMat


ASCENT = 1635
DESCENT = 410
OLD_EM = 1000
EM = ASCENT + DESCENT
HANKAKU_KANA = (0xFF61, 0xFFA0)
OBLIQUE_SKEW = 0.2

try:
    SCALE = float(getenv("MIGU1M_SCALE", "82")) / 100
except ValueError:
    SCALE = 0.82
X_TO_CENTER = EM * (1 - SCALE) / 2


def modify(in_file):
    font = fontforge.open(in_file)
    _set_new_em(font)
    _set_proportion(font)
    _zenkaku_space(font)
    out_file = f"modified-{in_file}"
    print(f"Generate {out_file}")
    font.generate(out_file, flags=("opentype",))
    return 0


def oblique(in_file):
    font = fontforge.open(in_file)
    _make_oblique(font)
    name, ext = splitext(in_file)
    in_style = name.split("-")[-1]
    style = "oblique" if in_style == "regular" else "bold-oblique"
    out_file = f"modified-ShipporiMincho-{style}{ext}"
    print(f"Generate {out_file}")
    font.generate(out_file, flags=("opentype",))
    return 0


def _set_new_em(font):
    """
    This sets new ascent & descent and scale glyphs.  This sets new ascent &
    descent before it sets em.  When in inverse, it does not change ascent &
    descent.
    """
    font.selection.all()
    font.unlinkReferences()
    font.ascent = round(float(ASCENT) / EM * OLD_EM)
    font.descent = round(float(DESCENT) / EM * OLD_EM)
    font.em = EM


def _set_proportion(font):
    scale = psMat.scale(SCALE)
    font.selection.all()
    processed_glyphs = set()  # 既に処理したグリフのコードポイントを保持するセット

    for glyph in list(font.selection.byGlyphs):
        codepoint = glyph.encoding
        if codepoint in processed_glyphs:
            continue  # 既に処理済みのグリフはスキップ
        processed_glyphs.add(codepoint)

        is_hankaku_kana = codepoint in range(*HANKAKU_KANA)
        x_to_center = X_TO_CENTER / 2 if is_hankaku_kana else X_TO_CENTER
        trans = psMat.translate(x_to_center, 0)
        mat = psMat.compose(scale, trans)
        glyph.transform(mat)
        glyph.width = round(EM / 2) if is_hankaku_kana else EM


def _zenkaku_space(font):
    font.selection.none()
    font.selection.select(0x2610)  # ☐  BALLOT BOX
    font.copy()
    font.selection.select(0x3000)  # 　 IDEOGRAPHIC SPACE
    font.paste()
    font.selection.select(0x271A)  # ✚  HEAVY GREEK CROSS
    font.copy()
    font.selection.select(0x3000)
    font.pasteInto()
    font.intersect()


def _make_oblique(font):
    mat = psMat.skew(OBLIQUE_SKEW)
    font.selection.all()
    font.transform(mat)
    font.removeOverlap()
