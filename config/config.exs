use Mix.Config

if Mix.env() in [:test] do
  config :logger,
    level: :warn,
    handle_otp_reports: false,
    handle_sasl_reports: false

  # config :appsignal_elli, appsignal_system: Appsignal.FakeSystem
  # config :appsignal_elli, appsignal_nif: Appsignal.FakeNif
  # config :appsignal_elli, appsignal_demo: Appsignal.FakeDemo
  config :appsignal_elli, appsignal_transaction: Appsignal.FakeTransaction
  # config :appsignal_elli, appsignal_diagnose_report: Appsignal.Diagnose.FakeReport
end
