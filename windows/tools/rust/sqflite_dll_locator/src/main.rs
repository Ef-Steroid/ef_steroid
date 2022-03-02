use std::fs;

use clap::Parser;

use sqflite_dll_locator::command::Command;
use sqflite_dll_locator::sqflite_dll_resolver::SqfliteDllResolver;

fn main() {
    let args: Command = Command::parse();
    let flutter_project_path = args.flutter_project_path;

    let sqflite_dll_path = SqfliteDllResolver::get_sqflite_dll_path(flutter_project_path.as_str());

    match args.installation_path {
        None => {
            println!("{}", sqflite_dll_path);
        }
        Some(installation_path) => {
            fs::copy(sqflite_dll_path, installation_path).expect("Unable to copy sqlite3.dll");
            println!("Done installing sqlite3.dll...");
        }
    }
}
