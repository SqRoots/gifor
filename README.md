# gifor: 项目介绍

## 1. 介绍

对于一些每帧只有一小部分有变化的GIF动图来说，Mathematica导出GIF图像时，每帧都使用了整幅图像，而不是仅发生变化的部分。对于这种情况，直接使用Mathematica导出的GIF图像文件占用空间会比较大。

而在GIF编码协议中，每帧可以是不大于整个图像尺寸的任意大小的图像，而且可以指定其位置，这就给解决上面的问题提供了一个有效的方法。

于是为了解决该问题，我看了几遍[《GRAPHICS INTERCHANGE FORMAT(sm) Version 89a》](https://www.w3.org/Graphics/GIF/spec-gif89a.txt)，也查了一些资料，最后终于用Mathematica实现了GIF的编码，这样就可以大大缩小每帧只有一小部分有变化的GIF动图文件占用的空间了。

本文主要介绍GIF编码协议的逻辑和流程。

Mathematica程序可在GitHub上下载：。

## 2. Demo

请参见：demo.nb

### 2.1 demo for gif

导入

```mathematica
gifPath = 
  FileNameJoin[{NotebookDirectory[], "gif", 
    "gif_encode__global_color_table.wl"}];
Get[gifPath];
?GIFEncodeGCT`gif
```

使用

```mathematica
imageDataList = {<|
     "position" -> <|"left" -> 0, "top" -> 0|>,
     "delay_time" -> 10,
     "data" -> ConstantArray[1, {100, 100}]
     |>,
    <|
     "position" -> <|"left" -> 0, "top" -> 0|>,
     "delay_time" -> 10,
     "data" -> ConstantArray[0, {100, 100}]
     |>}~Join~Table[<|
     "position" -> <|"left" -> RandomInteger[70], 
       "top" -> RandomInteger[70]|>,
     "delay_time" -> 10,
     "data" -> RandomInteger[{0, 1}, {20, 20}]
     |>, {10}];

file = "D:/12312312312.gif";
tt = GIFEncodeGCT`gif[file,
   <|"width" -> 100, "height" -> 100|>,
   {{0, 0, 0}, {255, 255, 255}},
   imageDataList,
   Infinity];
```



### 2.2 demo for VLZW

导入

```mathematica
lzwPath = 
  FileNameJoin[{NotebookDirectory[], "gif", 
    "variable_length_code_LZW_compression.wl"}];
Get[lzwPath];
?VLZWCompress`VLZW
```

使用

```mathematica
VLZWCompress`VLZW[RandomInteger[6, 100], 3]
```

