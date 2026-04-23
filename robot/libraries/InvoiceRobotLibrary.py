# -*- coding: utf-8 -*-
"""Bridge keywords: reuse logic dari automation/validators.py."""
import os
import sys

from robot.api.deco import keyword


def _ensure_project_root_on_sys_path():
    """
    Cari folder yang berisi paket 'automation' (ada automation/validators.py)
    lalu prepand ke sys.path. Tahan pindah folder/IDE/CWD.
    """
    start = os.path.dirname(os.path.abspath(__file__))
    p = start
    for _ in range(10):
        candidate = os.path.join(p, "automation", "validators.py")
        if os.path.isfile(candidate):
            if p not in sys.path:
                sys.path.insert(0, p)
            return
        parent = os.path.dirname(p)
        if parent == p:
            break
        p = parent
    # Fallback: dua level di atas robot/libraries/
    fallback = os.path.normpath(os.path.join(start, os.pardir, os.pardir))
    if os.path.isfile(os.path.join(fallback, "automation", "validators.py")):
        if fallback not in sys.path:
            sys.path.insert(0, fallback)
        return
    raise ImportError(
        "Tidak menemukan automation/validators.py. Cari dimulai dari {!r}.".format(start)
    )


_ensure_project_root_on_sys_path()

# Gagal cepat saat library di-load, bukan saat keyword pertama kali
from automation.validators import (  # noqa: E402
    compare_invoice_records,
    compute_pending_unbilled_totals,
)


def _as_plain_dict(obj):
    if obj is None:
        return {}
    if isinstance(obj, dict):
        return dict(obj)
    try:
        return dict(obj)
    except TypeError:
        return obj


class InvoiceRobotLibrary:
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    @keyword("Compare Invoice List Item To Detail")
    def compare_invoice_list_item_to_detail(self, list_inv, detail_inv):
        diffs = compare_invoice_records(_as_plain_dict(list_inv), _as_plain_dict(detail_inv))
        if diffs:
            raise AssertionError("; ".join(diffs))

    @keyword("Unbilled Summary Should Match Pending Calculation")
    def unbilled_summary_should_match_pending_calculation(self, invoices, summary):
        exp_total, exp_after = compute_pending_unbilled_totals(list(invoices))
        summ = _as_plain_dict(summary)
        act_total = float(summ["totalUnbilled"])
        act_after = float(summ["unbilledAfterTax"])
        if abs(act_total - exp_total) > 1e-6:
            raise AssertionError("totalUnbilled expected {} actual {}".format(exp_total, act_total))
        if abs(act_after - exp_after) > 1e-6:
            raise AssertionError("unbilledAfterTax expected {} actual {}".format(exp_after, act_after))
        tr = summ.get("taxRate", 0.1)
        if abs(float(tr) - 0.1) > 1e-9:
            raise AssertionError("taxRate expected 0.1 actual {}".format(tr))
