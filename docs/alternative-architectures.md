# Alternative architectures

As stated in the [Prerequisites](prerequisites.md), currently only `x86_64` is fully supported. However, it is possible to set the target architecture, and some tools can be built on the host or other measures can be used.

To that end add the following variable to your `vars.yml` file (see [Configuring playbook](configuring-playbook.md)):

```yaml
nextcloud_architecture: <your-nextcloud-server-architecture>
```

Currently supported architectures are the following:
- `amd64` (the default)
- `arm64`
- `arm32`

so for the Raspberry Pi, the following should be in your `vars.yml` file:

```yaml
nextcloud_architecture: "arm32"
```
