## Evergreen Development Notes

### Local testing

Test changes before pushing:

```bash
just build                    # Build container image
just build && just build-iso  # Build installation ISO
just build-qcow2              # Build VM disk image
just run-vm-qcow2             # Test in browser-based VM
```
