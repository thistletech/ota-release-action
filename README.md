# ota-release-action: OTA Update Action with Thistle

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
|                         <a name="input_signing_key"></a>[signing_key](#input_signing_key)                         | string |  false   |           |                             Minisign signing key in Thistle <br>format. Required only if signing_key_mangement <br>is "local"                               |
|          <a name="input_signing_key_mangement"></a>[signing_key_mangement](#input_signing_key_mangement)          | string |   true   | `"local"` |                                             Incidates how the signing key <br>is managed ("local" or "remote")                                              |
|           <a name="input_signing_key_password"></a>[signing_key_password](#input_signing_key_password)            | string |  false   |           |           Password for the signing key. <br>Required only if signing_key_mangement is <br>"local" and the signing key <br>is password protected             |
|                 <a name="input_zip_archive_path"></a>[zip_archive_path](#input_zip_archive_path)                  | string |  false   |           |                                      Path to the zip archive <br>file. Required only if release_type <br>is "archive"                                       |

<!-- AUTO-DOC-INPUT:END -->


## Example usage

TODO
