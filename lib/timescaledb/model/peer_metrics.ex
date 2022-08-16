defmodule Membrane.RTC.Engine.TimescaleDB.Model.PeerMetrics do
  @moduledoc """
  Model representing set of peer metrics from `Membrane.RTC.Engine` metrics report.
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
          time: NaiveDateTime.t() | nil,
          peer_id: String.t() | nil,
          "ice.binding_requests_received": non_neg_integer() | nil,
          "ice.binding_responses_sent": non_neg_integer() | nil,
          "ice.bytes_received": non_neg_integer() | nil,
          "ice.bytes_sent": non_neg_integer() | nil,
          "ice.packets_received": non_neg_integer() | nil,
          "ice.packets_sent": non_neg_integer() | nil
        }

  @primary_key false
  schema "peers_metrics" do
    field :time, :naive_datetime_usec
    field :peer_id, :string

    field :"ice.binding_requests_received", :integer
    field :"ice.binding_responses_sent", :integer
    field :"ice.bytes_received", :integer
    field :"ice.bytes_sent", :integer
    field :"ice.packets_received", :integer
    field :"ice.packets_sent", :integer
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(schema, params) do
    required_fields = [:time, :peer_id]

    casted_fields =
      required_fields ++
        [
          :"ice.binding_requests_received",
          :"ice.binding_responses_sent",
          :"ice.bytes_received",
          :"ice.bytes_sent",
          :"ice.packets_received",
          :"ice.packets_sent"
        ]

    schema
    |> cast(params, casted_fields)
    |> validate_required(required_fields)
  end
end
