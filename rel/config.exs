["rel", "plugins", "*.exs"]
  |> Path.join()
  |> Path.wildcard()
  |> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    default_release: :default,
    default_environment: Mix.env()

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"O7I{NQBi(|au%!N56S3,>PASLH)^3)_lnjtJU!wtmA4zJ[3>qYm7vzoJ}R*C|J=j"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set vm_args: "rel/vm.args"
end

release :release_ping do
  set version: current_version(:release_ping)
  set applications: [
    :runtime_tools
  ]
  set commands: [
    "migrate": "rel/commands/migrate.sh",
    "db.create": "rel/commands/create_db.sh",
  ]
end
