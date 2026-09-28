Finley_51953 Universal LuAshitacast Profile

Runtime directory:
  Ashita\config\addons\LuAshitacast\Finley_51953\

Place Universal.lua and the 22 JOB.lua wrapper files in that directory.
The wrappers all load Universal.lua.

2026-09-16 RDM macro / Dynamic Enspell refinement:
- Dynamic Enspell faithfully preserves the original Claude Finley_RDM.lua
  six-element selection logic. Only Enfire, Enblizzard, Enaero, Enstone,
  Enthunder, and Enwater can be selected.
- Ctrl-\ is bound only when RDM is main or support job. Enlight/Endark are
  never selected.
- RDM main-job macro deck: Ctrl-` through Ctrl-= plus RDM WS macros.
- RDM Ctrl-9/0/-/= are Blaze Spikes / Ice Spikes / Shock Spikes / Phalanx.
- RDM Alt-5 is Blind II.
- WHM main/support binds Ctrl-` to Erase, overriding RDM Cure II when both
  RDM and WHM are present.
- NIN main/support binds Alt-[ / Alt-] to Utsusemi: Ichi / Ni.
- DNC main/support binds Alt-[ / Alt-] / Alt-' to Quickstep / Box Step /
  Spectral Jig.
- Job-owned binds are explicitly unbound before the active main/support-job
  macro set is installed; no /unbind all is used.
