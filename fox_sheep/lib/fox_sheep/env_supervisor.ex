defmodule FoxSheep.EnvSupervisor do
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg)
  end

  def init({fox_number, sheep_number}) do
    # 传入羊的数量和狼的数量
    fox_process_list =
      Enum.map(1..fox_number, fn i ->
        Supervisor.child_spec({FoxSheep.Fox, ["fox_#{i}"]}, id: :"fox_#{i}")
      end)

    sheep_process_list =
      Enum.map(1..sheep_number, fn i ->
        Supervisor.child_spec({FoxSheep.Sheep, ["sheep_#{i}"]}, id: :"sheet_#{i}")
      end)

    children_process =
      [{FoxSheep.Env, [fox_number, sheep_number]}] ++ fox_process_list ++ sheep_process_list

    Supervisor.init(children_process, strategy: :one_for_one)
  end
end
