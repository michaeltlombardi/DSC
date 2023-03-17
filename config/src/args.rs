use clap::{Parser, Subcommand};
use std::str::FromStr;

#[derive(Debug, PartialEq, Eq)]
pub enum OutputFormat {
    Json,
    PrettyJson,
    Yaml,
}

impl FromStr for OutputFormat {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s.to_ascii_lowercase().as_str() {
            "json" => Ok(OutputFormat::Json),
            "prettyjson" => Ok(OutputFormat::PrettyJson),
            "yaml" => Ok(OutputFormat::Yaml),
            _ => Err(format!("Invalid output format: {}", s)),
        }
    }
}

#[derive(Debug, Parser)]
#[clap(name = "config", version = "0.1.0", about = "Discover and invoke DSC resources", long_about = None)]
pub struct Args {
    /// The subcommand to run
    #[clap(subcommand)]
    pub subcommand: SubCommand,
    /// Whether to use the cache or not
    #[clap(short = 'n', long)]
    pub no_cache: bool,
    #[clap(short = 'f', long)]
    pub format: Option<OutputFormat>,
}

#[derive(Debug, PartialEq, Eq, Subcommand)]
pub enum SubCommand {
    #[clap(name = "list", about = "List resources")]
    List {
        /// Optional filter to apply to the list of resources
        resource_name: Option<String>,
    },
    #[clap(name = "get", about = "Get the resource", arg_required_else_help = false)]
    Get {
        #[clap(short, long, help = "The name or DscResource JSON of the resource to invoke `get` on")]
        resource: String,
        #[clap(short, long, help = "The input to pass to the resource as JSON")]
        input: Option<String>,
    },
    #[clap(name = "set", about = "Set the resource", arg_required_else_help = false)]
    Set {
        #[clap(short, long, help = "The name or DscResource JSON of the resource to invoke `set` on")]
        resource: String,
        #[clap(short, long, help = "The input to pass to the resource as JSON")]
        input: Option<String>,
    },
    #[clap(name = "test", about = "Test the resource", arg_required_else_help = false)]
    Test {
        #[clap(short, long, help = "The name or DscResource JSON of the resource to invoke `test` on")]
        resource: String,
        #[clap(short, long, help = "The input to pass to the resource as JSON")]
        input: Option<String>,
    },
}
