@echo off
rem
rem Teamcenter Visualization 11.2.3 Uninstallation Information
rem
rem This batch file can be used to completely uninstall Teamcenter
rem Visualization 9.1.  In a normal uninstall (from Add/Remove
rem programs) some information may be left behind on the machine.
rem For example, registry settings that may be used for migration
rem to a new version will remain on the machine.  Though normal,
rem this may or may not be desireable.
rem
rem Additional cleanup can be performed by the uninstall process
rem by passing arguments to the uninstall command.  The additional
rem actions are controlled through the CLEANUP_LEVEL property:  This
rem is a numeric value with encoded values controlling
rem the actions to take.   Multiple actions are permitted by using
rem the total of any individual action values.
rem
rem Value:      Action:
rem   1        Remove file associations
rem   2        Remove "VisView" registry keys (current version + retained)
rem   4        Remove "VisView" registry keys (ALL versions + retained)
rem   8        Remove entire <INSTALLDIR> directory hierarchy
rem
rem Note that under normal circumstances, the entire <INSTALLDIR> directory
rem is usually deleted.  The only case of it being left behind would be if
rem it were there before installing, or if additional files have been placed
rem there by a user.
rem
rem Examples:
rem
rem 1. Basic Silent uninstall
rem msiexec -x {99DA3025-A2D1-4B6A-AAFB-8644A03BF0D3} -qb
rem
rem 2. Silent uninstall, remove file associations only
rem msiexec -x {99DA3025-A2D1-4B6A-AAFB-8644A03BF0D3} -qb CLEANUP_LEVEL=1
rem
rem 3. Silent uninstall, remove file associations, version specific registry keys,
rem and the entire <INSTALLDIR> hierarchy (1 + 2 + 8 = 11)
rem msiexec -x {99DA3025-A2D1-4B6A-AAFB-8644A03BF0D3} -qb CLEANUP_LEVEL=11

