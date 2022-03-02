use std::fs::File;
use std::io::BufReader;
use std::path::PathBuf;

use url::Url;

use crate::dart_package_config::{DartPackageConfig, PubPackage};

pub struct SqfliteDllResolver {}

impl SqfliteDllResolver {
    pub fn get_sqflite_dll_path(flutter_project_path: &str) -> String {
        let mut flutter_project_path = PathBuf::from(flutter_project_path);
        Self::push_multiple_paths(&mut flutter_project_path, vec!(".dart_tool", "package_config.json"));
        if !flutter_project_path.exists()
        {
            panic!("Could not find package_config.json. Did you run `flutter pub get`?");
        }

        let dart_package_config = Self::get_dart_package_config(flutter_project_path);

        let sqflite_common_ffi_package = Self::get_sqflite_common_ffi_package(dart_package_config);

        let sqflite_common_ffi_package_uri = Url::parse(sqflite_common_ffi_package.root_uri.as_str()).unwrap();
        let mut sqflite_common_ffi_package_path = sqflite_common_ffi_package_uri.to_file_path().unwrap();
        let sqflite_common_ffi_package_path = Self::push_multiple_paths(&mut sqflite_common_ffi_package_path, vec!("lib", "src", "windows", "sqlite3.dll"));
        if !sqflite_common_ffi_package_path.exists()
        {
            panic!("Could not find sqlite3.dll under path '{}'.", sqflite_common_ffi_package_path.to_str().unwrap());
        }

        String::from(sqflite_common_ffi_package_path.to_str().unwrap())
    }

    fn get_sqflite_common_ffi_package(dart_package_config: DartPackageConfig) -> PubPackage {
        let packages = dart_package_config.packages;
        let sqflite_common_ffi_package: &PubPackage = packages.iter()
            .find(|&x| x.name == "sqflite_common_ffi")
            .unwrap_or_else(|| panic!("Could not find sqflite_common_ffi in pub deps"));
        sqflite_common_ffi_package.clone()
    }

    fn get_dart_package_config(flutter_project_path: PathBuf) -> DartPackageConfig {
        let dart_package_config_json_file = File::open(flutter_project_path.as_path().to_str().unwrap()).unwrap();
        let dart_package_config_json_reader = BufReader::new(dart_package_config_json_file);
        let dart_package_config: DartPackageConfig = serde_json::from_reader(dart_package_config_json_reader).unwrap();
        dart_package_config
    }

    fn push_multiple_paths<'a>(path_buf: &'a mut PathBuf, paths: Vec<&str>) -> &'a mut PathBuf {
        for p in paths {
            path_buf.push(p);
        }

        path_buf
    }
}
