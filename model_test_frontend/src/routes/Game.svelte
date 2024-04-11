<script lang="ts">
  import { createEventDispatcher, onMount } from "svelte";
  export let button_text1 = "生成一局新游戏";
  export let create_text = "创建新的actor";
  export let input_question_text = "输入你要问的问题";
  let game_id = "";
  let game_log = [""];

  let show_dialog = false;
  let show_question_dialog = false;
  let selected_option = "";
  let input_name = "";

  let input_question = "";
  let ask_actor_name = "";
  const dispatch = createEventDispatcher();

  onMount(() => {
    game_log = document.getElementById("game_log");
    setInterval(get_observation, 5000);
  });

  async function new_game() {
    try {
      const response = await fetch("http://localhost:4000/new");
      const data = await response.json();
      game_id = data["game_id"];
    } catch (error) {
      console.error("请求失败: ", error);
    }
  }

  async function new_actor(actor_type = "", actor_name = "") {
    try {
      const params = {
        game_id,
        actor_type,
        actor_name,
      };
      const query_string = new URLSearchParams(params).toString();
      const url = `http://localhost:4000/new_actor?${query_string}`;
      const response = await fetch(url);
    } catch (error) {
      console.log("error: ", error);
    }
  }

  async function get_observation() {
    try {
      const params = {
        game_id,
      };
      const query_string = new URLSearchParams(params).toString();
      const url = `http://localhost:4000/get_game_observation?${query_string}`;
      const response = await fetch(url);
      const data = await response.json();
      game_log = data["conversation_cache"];
      console.log(game_log);
    } catch (error) {
      console.log("error: ", error);
    }
  }

  async function question(actor_name = "", question = "") {
    try {
      const params = {
        game_id,
        actor_name,
        question,
      };
      const query_string = new URLSearchParams(params).toString();
      const url = `http://localhost:4000/question?${query_string}`;
      const response = await fetch(url);
    } catch (error) {
      console.log("error: ", error);
    }
  }

  function open_dialog() {
    show_dialog = true;
  }

  function close_dialog() {
    show_dialog = false;
    selected_option = "";
    input_name = "";
  }

  function submit_form() {
    // dispatch("formSubmit", { option: selected_option, name: input_name })
    console.log(selected_option, input_name);
    new_actor(selected_option, input_name);
    close_dialog();
  }

  function open_question_dialog() {
    show_question_dialog = true;
  }

  function close_question_dialog() {
    show_question_dialog = false;
  }

  function submit_question_form() {
    question(ask_actor_name, input_question);
    close_question_dialog();
  }
</script>

<div>
  <button on:click={new_game}>{button_text1}</button>

  {#if game_id}
    <p>
      <span>当前的room_id值是 {game_id}</span>
    </p>

    <button on:click={open_dialog}>{create_text}</button>

    <button on:click={open_question_dialog}>{input_question_text}</button>
  {/if}

  <pre id="game_log">
    {#each game_log as log}
      <span>{log}</span>
      <br />
    {/each}
  </pre>
</div>

{#if show_question_dialog}
  <div class="overlay">
    <div class="dialog">
      <h3>输入问题</h3>
      <input
        type="text"
        bind:value={input_question}
        placeholder="输入你要问的问题"
      />
      <input
        type="text"
        bind:value={ask_actor_name}
        placeholder="输入你要发送的actor名字"
      />
      <div class="buttons">
        <button on:click={submit_question_form}>提交</button>
        <button on:click={close_question_dialog}>取消</button>
      </div>
    </div>
  </div>
{/if}

{#if show_dialog}
  <div class="overlay">
    <div class="dialog">
      <h3>创建actor</h3>
      <label>
        <input
          type="radio"
          bind:group={selected_option}
          value="question_actor"
        />
        question_actor
      </label>
      <label>
        <input type="radio" bind:group={selected_option} value="answer_actor" />
        answer_actor
      </label>
      <label>
        <input type="radio" bind:group={selected_option} value="critic_actor" />
        critic_actor
      </label>
      <input type="text" bind:value={input_name} placeholder="输入文本" />
      <div class="buttons">
        <button on:click={submit_form}>提交</button>
        <button on:click={close_dialog}>取消</button>
      </div>
    </div>
  </div>
{/if}

<style>
  button {
    margin: 0.5rem;
  }

  .overlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 9999;
  }

  .dialog {
    background-color: white;
    padding: 1rem;
    border-radius: 4px;
    text-align: center;
  }

  .dialog h3 {
    margin-top: 0;
  }

  .buttons {
    margin-top: 1rem;
  }

  .buttons button {
    margin-left: 0.5rem;
  }
</style>
