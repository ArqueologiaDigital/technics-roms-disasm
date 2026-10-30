"""The helpers of ../port-edits-v1_15i/_edit.py, aimed at hdae5000_v1_10i/."""
import importlib.util
import os

os.environ.setdefault("PORT_TREE", "hdae5000_v1_10i")
_p = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "port-edits-v1_15i", "_edit.py")
_spec = importlib.util.spec_from_file_location("_edit_v1_15i", _p)
_m = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_m)
globals().update({k: v for k, v in vars(_m).items() if not k.startswith("__")})
