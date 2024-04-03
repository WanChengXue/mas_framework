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
      
    const svgNS = 'http://www.w3.org/2000/svg'; // SVG命名空间
    let color;

    // 根据动物类型设定颜色
    if (type === 'fox') {
        color = '#FFA500'; // 示例：狐狸为橙色
    } else if (type === 'sheep') {
        color = '#FFFFFF'; // 示例：羊为白色
    }

    // 创建一个新的SVG矩形元素
    const rect = document.createElementNS(svgNS, 'rect');

    // 设置矩形的位置、尺寸和颜色属性
    rect.setAttribute('x', x - length / 2);
    rect.setAttribute('y', y - width / 2);
    rect.setAttribute('width', length);
    rect.setAttribute('height', width);
    rect.setAttribute('fill', color);

    // 将矩形添加到SVG画布中
    const svgElement = document.querySelector('svg'); // 假设你的SVG元素在页面上已经存在
    svgElement.appendChild(rect);

    return rect; // 返回创建的矩形元素，以便于后续动画或其他操作
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