# Fix LED Black Screen Issue After Resume

## Temporary Test

At the GRUB menu:

1. Select the Arch Linux entry and press `e`.
2. Append the following parameter to the `linux` line:

```text
i915.enable_psr=0
```

3. Boot with `Ctrl+X` or `F10`.

Verify:

```bash
cat /proc/cmdline
cat /sys/module/i915/parameters/enable_psr
```

Expected value: `0`.

## Make the Fix Permanent

Edit GRUB defaults:

```bash
sudo nano /etc/default/grub
```

Append `i915.enable_psr=0` to `GRUB_CMDLINE_LINUX_DEFAULT`, preserving existing parameters.

Regenerate the GRUB configuration:

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

Reboot and verify that the parameter is active.

