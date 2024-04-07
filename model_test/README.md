# ModelTest

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix


## why?
现有的多智能体仿真项目，所有的智能体都是提前给了链接关系，但是在实际场景中，智能体和智能体之间的链接是随着时间在不停变化的，本项目就是要在一个随时变化的评测场景中，给出一个具体的评测任务的demo

## how?
本项目的实现过程分成以下几个步骤：
- 抽象core的开发
- 规则的抽象
- 评测场景具体应用
- 提供SDK操作项目中的某些智能体
- 提供可视化界面，类似聊天室的交互形式

