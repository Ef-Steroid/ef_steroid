use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone)]
pub struct DartPackageConfig {
    pub packages: Vec<PubPackage>,
}

#[derive(Serialize, Deserialize, Clone)]
pub struct PubPackage {
    /// The name of the package.
    pub name: String,

    /// The version of the package.
    #[serde(alias = "rootUri")]
    pub root_uri: String,
}
