<!-- AnimalMap.svelte -->
<script>
    import { onMount } from 'svelte';
  
    let animals = [];
    let worldSize = {
      length: 0,
      width: 0
    };
  
    // 假设有个fetchAnimals()函数，它从后端获取实时数据
    async function fetchAnimals() {
      const response = await fetch('/api/animal-positions');
      const data = await response.json();
      
      animals = data.location.map(([name, x, y], index) => ({
        name,
        type: name.startsWith('fox') ? 'fox' : 'sheep',
        x: x,
        y: y,
        size: name.startsWith('fox') ? { length: data.fox_length, width: data.fox_width } : { length: data.sheep_length, width: data.sheep_width },
      }));
      
      worldSize.length = data.world_length;
      worldSize.width = data.world_width;
    }
  
    onMount(async () => {
      setInterval(fetchAnimals, 1000 / 60); // 每秒60次请求
    });
  
    // 这里假设你已经有了一个基于SVG或者其他图形库的绘制函数
    function drawAnimal({ x, y, length, width, type }) {
      // 根据动物类型和尺寸，在画布上绘制动物
      // ...
    }
  </script>
  
  <svg width="{worldSize.width}" height="{worldSize.length}">
    {#each animals as animal}
      <g>
        <!-- 调用drawAnimal函数在此处绘制每个动物 -->
        {#await drawAnimal(animal)}
          <!-- 可能的加载指示器，如果drawAnimal是异步的话 -->
        {:then}
          <!-- 动物绘制完成后的呈现 -->
        {:catch error}
          <!-- 错误处理 -->
        {/await}
      </g>
    {/each}
  </svg>