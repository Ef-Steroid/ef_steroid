use clap::Parser;

#[derive(Parser, Debug)]
#[clap(author, version, about, long_about = None)]
pub struct Command {
    #[clap(long)]
    pub flutter_project_path: String,

    #[clap(long)]
    pub installation_path: Option<String>,
}
