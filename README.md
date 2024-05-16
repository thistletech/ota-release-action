# ota-release-action: OTA Update Action with Thistle

[Thistle Technologies](https://thistle.tech/) provides a software solution to
over-the-air (OTA) updates for embedded devices.  This action creates an OTA
update release, and publishes it to [Thistle's backend
platform](https://app.thistle.tech/), to update devices running the [Thistle
Update Client (TUC)](https://docs.thistle.tech/update/cli#update-client-usage).

## Example Usage

To use this action, one needs to create an account in the [Thistle Control
Center](https://app.thistle.tech), and obtain the API token ("Project Access
Token"). In case a locally managed OTA update signing key is used (which is the
only supported option currently), one also needs to go through the
[Configuration
step](https://docs.thistle.tech/update/get_started/file_update#configuration) to
create a password-protected [Minisign](https://jedisct1.github.io/minisign/)
private key with the `trh init` command.

An example workflow is as follows. Confidential information, such as the
aforementioned project access token, private signing key, and signing key
password are saved as GitHub repository secrets.

```yaml
name: 'OTA Release'

on:
  push:
    tags:
      # Trigger release by tagging
      - 'release-v*'

jobs:
  ota_release:
    name: 'OTA Release'
    runs-on: 'ubuntu-latest'
    steps:
      - name: 'Checkout source'
        uses: 'actions/checkout@v4'
    
      - name: 'Create artifacts for OTA release'
        run: |
          ...
          [build artifacts from source]
          ...
          rm -rf artifacts
          mkdir -p artifacts
          ...
          [copy built artifacts to directory artifacts/]
          ...

      - name: 'OTA Release'
        uses: 'thistletech/ota-release-action@v1'
        with:
          release_type: 'file'
          persist_dir: '/tmp/persist'
          artifacts_dir: 'artifacts'
          base_install_path_on_device: '/tmp/ota'
          project_access_token: ${{ secrets.PROJECT_ACCESS_TOKEN }}
          signing_key_management: 'local'
          signing_key: ${{ secrets.SIGNING_KEY }}
          signing_key_password: ${{ secrets.SIGNING_KEY_PASSWORD }}
```

## Inputs

<!-- AUTO-DOC-INPUT:START - Do not remove or modify this section -->

|                                                       INPUT                                                       |  TYPE  | REQUIRED |  DEFAULT  |                                                                         DESCRIPTION                                                                         |
|-------------------------------------------------------------------------------------------------------------------|--------|----------|-----------|-------------------------------------------------------------------------------------------------------------------------------------------------------------|
|                      <a name="input_artifacts_dir"></a>[artifacts_dir](#input_artifacts_dir)                      | string |  false   |           |                                              Path to the directory where <br>OTA update artifacts are stored                                                |
| <a name="input_base_install_path_on_device"></a>[base_install_path_on_device](#input_base_install_path_on_device) | string |  false   |           | Path to base directory on <br>device file system where OTA <br>update artifacts will be installed. <br>Required if release_type is "file" <br>or "archive"  |
|                         <a name="input_persist_dir"></a>[persist_dir](#input_persist_dir)                         | string |   true   |           |                                                Path to the directory where <br>the device can persist data                                                  |
|           <a name="input_project_access_token"></a>[project_access_token](#input_project_access_token)            | string |   true   |           |                           Project access token can be <br>obtained from the project settings <br>page in Thistle Control Center                             |
|                       <a name="input_release_type"></a>[release_type](#input_release_type)                        | string |   true   | `"file"`  |                                                     Release type ("file", "zip_archive", or "rootfs")                                                       |
|                   <a name="input_rootfs_img_path"></a>[rootfs_img_path](#input_rootfs_img_path)                   | string |  false   |           |                                      Path to the rootfs image <br>file. Required only if release_type <br>is "rootfs"                                       |
|                         <a name="input_signing_key"></a>[signing_key](#input_signing_key)                         | string |  false   |           |                             Minisign signing key in Thistle <br>format. Required only if signing_key_management <br>is "local"                              |
|        <a name="input_signing_key_management"></a>[signing_key_management](#input_signing_key_management)         | string |   true   | `"local"` |                                             Indicates how the signing key <br>is managed ("local" or "remote")                                              |
|           <a name="input_signing_key_password"></a>[signing_key_password](#input_signing_key_password)            | string |  false   |           |           Password for the signing key. <br>Required only if signing_key_management is <br>"local" and the signing key <br>is password protected            |
|                 <a name="input_zip_archive_path"></a>[zip_archive_path](#input_zip_archive_path)                  | string |  false   |           |                                      Path to the zip archive <br>file. Required only if release_type <br>is "archive"                                       |

<!-- AUTO-DOC-INPUT:END -->

