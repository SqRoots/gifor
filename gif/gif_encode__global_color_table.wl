(* ::Package:: *)

(*GIF\:7f16\:7801*)
(*\:4ec5\:4f7f\:7528\:5168\:5c40\:989c\:8272\:8868*)
(*\:4f5c\:8005\:ff1a\:674e\:5ba3\:ff08https://lixuan.xyz\:ff09*)
(*2019-10-29*)

Get[FileNameJoin[{NotebookDirectory[],"gif","variable_length_code_LZW_compression.wl"}]];

BeginPackage["GIFEncodeGCT`",{"VLZWCompress`"}]

gif::usage ="
\:3010\:8f93\:5165\:3011\:ff1a\:5b58\:50a8\:8def\:5f84\:ff0c\:56fe\:50cf\:5c3a\:5bf8\:ff0c\:5168\:5c40\:989c\:8272\:8868\:ff0c\:56fe\:50cf\:6570\:636e\:5217\:8868\:ff0c\:91cd\:590d\:64ad\:653e\:6b21\:6570
\:3010\:8f93\:51fa\:3011\:ff1a<|\"path\"->\:5b58\:50a8\:8def\:5f84,\"data\"->gif\:56fe\:50cf\:6570\:636e\:6d41|>
\:3010\:6ce8\:3011\:ff1a\:6240\:6709\:5e16\:90fd\:4f7f\:7528\:5168\:5c40\:989c\:8272\:8868
-------------------------------------------------------
- \:3010\:5b58\:50a8\:8def\:5f84\:3011\:ff1a\:7edd\:5bf9\:8def\:5f84
- \:3010\:56fe\:50cf\:6570\:636e\:3011\:ff1a{
   <|
     \"position\"\[Rule]<|\"left\"\[Rule]0,\"top\"\[Rule]0|>,
     \"delay_time\"\[Rule]10,
     \"data\"\[Rule]{{index1,index2,...},...}
   |>,
   <||>,<||>,...
}
- \:3010\:56fe\:50cf\:5c3a\:5bf8\:3011\:ff1a<|\"width\"\[Rule]100,\"height\"\[Rule]100|>
- \:3010\:5168\:5c40\:989c\:8272\:8868\:3011[\:4e8c\:7ef4\:5217\:8868]\:ff1a{{r0,g0,b0},{0,0,0},{255,255,255},...}
- \:3010\:91cd\:590d\:64ad\:653e\:6b21\:6570\:3011[\:6574\:6570]\:ff1a1 | 2 | ... | Infinity
"

Begin["`Private`"]
(*--------------------------------------------------------*)
(*\:6700\:7ec8\:8f93\:51fa\:51fd\:6570*)
(*\:8f93\:5165\:ff1a
savePath              \:5b57\:7b26\:4e32;
imageSize             \:5b57\:5178   <|"width"\[Rule]200,"height"\[Rule]100|>;
globalColorTable      \:5217\:8868   {{r,g,b},{0,128,255},...};
repetitTimes          \:6574\:6570   1~65535\:ff0cInfinity;
imageDataList         \:5217\:8868\:ff1a{<|"position"\[Rule]<|"left"\[Rule]0,"top"\[Rule]0|>,"delay_time"\[Rule]10,"data"\[Rule]{{index1,index2,...},...}|>,...};
*)
gif[savePath_,imageSize_,globalColorTable_,imageDataList_,repetitTimes_: Infinity]:=Module[{
imageWidth=imageSize["width"],
imageHeight=imageSize["height"],
codeSize=Ceiling[Log[2,Length[Union[globalColorTable]]]],
exportGIFData
},

exportGIFData=Flatten[{
cHeader,

fLogicalScreenDescriptor[imageWidth,imageHeight,<|
"Global Color Table Flag"->{1},
"Color Resolution"->{1,1,1},
"Sort Flag"->{0},
"Size of Global Color Table"->IntegerDigits[codeSize-1,2,3]
|>],

(*Global Color Table*)
fGlobalColorTable[globalColorTable],

(*Data Application Extension:\:91cd\:590d\:64ad\:653e\:6b21\:6570*)
fApplicationExtension[repetitTimes],

(*Data*)
Table[
{imageHeight,imageWidth}=Dimensions[imageData["data"]];

{
fGraphicControlExtension[Lookup[imageData,"delay_time",100]],
fImageDescriptor[
Lookup[imageData,"position",<|"left"->0,"top"->0|>]["left"],
Lookup[imageData,"position",<|"left"->0,"top"->0|>]["top"],
imageWidth,
imageHeight,
Lookup[imageData,"local_color_table_flag",{0}],
Lookup[imageData,"size_of_local_color_table",{0,0,0}]
],
If[Lookup[imageData,"local_color_table_flag",{0}]=={0},
fImageData[Flatten[imageData["data"]],codeSize],
{fLocalColorTable[Lookup[imageData,"local_color_table"]],fImageData[Flatten[imageData["data"]],codeSize]}
]
},{imageData,imageDataList}],

cTrailer}];
BinaryWrite[savePath, exportGIFData];
Close[savePath];(*\:5343\:4e07\:522b\:5fd8\:4e86*)
<|"path"->savePath,"data"->exportGIFData|>
];

(*========================================================*)
(*\:5934\:90e8*)
cHeader={71,73,70,56,57,97};

(*--------------------------------------------------------*)
(*\:903b\:8f91\:5c4f\:5e55\:63cf\:8ff0\:5668 - GIF\:7684\:57fa\:672c\:5c5e\:6027*)
fLogicalScreenDescriptor[width_:30,height_:30,
packedFields_:<|
"Global Color Table Flag"->{1},
"Color Resolution"->{1,1,1},
"Sort Flag"->{0},
"Size of Global Color Table"->{0,0,0}
|>,
backgroundColorIndex_:1,
pixelAspectRatio_:0]:=Flatten[{
Reverse@IntegerDigits[width,256,2],(*\:8ba1\:7b97\:56fe\:50cf\:7684\:5bbd*)
Reverse@IntegerDigits[height,256,2],(*\:8ba1\:7b97\:56fe\:50cf\:7684\:9ad8*)
FromDigits[Flatten[packedFields/@{"Global Color Table Flag","Color Resolution","Sort Flag","Size of Global Color Table"}],2],
backgroundColorIndex,
pixelAspectRatio
}];

(*--------------------------------------------------------*)
(*\:5168\:5c40\:989c\:8272\:8868\:ff0ccolor_List={{r,g,b},{r,g,b},...}*)
fGlobalColorTable[color_List]:=Module[{size=Ceiling[Log[2,Length[Union[color]]]]},
Flatten@Table[If[k>Length[color],{0,0,0},color[[k]]],{k,2^size}]
];

(*--------------------------------------------------------*)
(*\:56fe\:5f62\:63a7\:5236\:6269\:5c55 - \:5e27\:663e\:793a\:65f6\:957f*)
Clear[fGraphicControlExtension];
fGraphicControlExtension[delayTime_:100]:=Module[{
ExtensionIntroducer=33,
GraphicControlLabel=249,
BlockSize=4,
PackedFields,
PackedFieldsReserved={0,0,0},
PackedFieldsDisposalMethod={0,0,0},
PackedFieldsUserInputFlag={0},
PackedFieldsTransparentColorFlag={0},
DelayTime=Reverse@IntegerDigits[delayTime,256,2],(*\:5355\:4f4d\:ff1a1/100\:79d2*)
TransparentColorIndex=255,
BlockTerminator=0
},
PackedFields=FromDigits[PackedFieldsReserved~Join~PackedFieldsDisposalMethod~Join~PackedFieldsUserInputFlag~Join~PackedFieldsTransparentColorFlag,2];
Flatten[{ExtensionIntroducer,GraphicControlLabel,BlockSize,PackedFields,DelayTime,TransparentColorIndex,BlockTerminator}]
];

(*--------------------------------------------------------*)
(*\:56fe\:50cf\:63cf\:8ff0\:5668 - \:5e27\:7684\:4f4d\:7f6e\:3001\:5c3a\:5bf8\:3001\:662f\:5426\:4f7f\:7528\:5c40\:90e8\:989c\:8272\:8868\:3001\:5c40\:90e8\:989c\:8272\:8868\:7684\:4f4d\:6570*)
fImageDescriptor[imageLeftPosition_,imageTopPosition_,imageWidth_,imageHeight_,
localColorTableFlage_:{0},
sizeOfLocalColorTable_:{0,0,0}
]:=Module[{
ImageSeparator=44,
ImageLeftPosition=Reverse@IntegerDigits[imageLeftPosition,256,2],
ImageTopPosition=Reverse@IntegerDigits[imageTopPosition,256,2],
ImageWidth=Reverse@IntegerDigits[imageWidth,256,2],
ImageHeight=Reverse@IntegerDigits[imageHeight,256,2],
PackedFields,
PackedFieldsLocalColorTableFlag=localColorTableFlage,(*\:662f\:5426\:4f7f\:7528\:5c40\:90e8\:989c\:8272\:8868*)
PackedFieldsInterlaceFlage={0},
PackedFieldsSortFlag={0},
PackedFieldsReserved={0,0},
PackedFieldsSizeOfLocalColorTable=sizeOfLocalColorTable(*\:5c40\:90e8\:989c\:8272\:8868\:957f\:5ea6*)
},
PackedFields=FromDigits[PackedFieldsLocalColorTableFlag~Join~PackedFieldsInterlaceFlage~Join~PackedFieldsSortFlag~Join~PackedFieldsReserved~Join~PackedFieldsSizeOfLocalColorTable,2];
Flatten[{ImageSeparator,
ImageLeftPosition,ImageTopPosition,
ImageWidth,ImageHeight,
PackedFields
}]
];

(*--------------------------------------------------------*)
(*\:5c40\:90e8\:989c\:8272\:8868*)
fLocalColorTable[color_List]:=Module[{size=Ceiling[Log[2,Length[Union[color]]]]},
Flatten@Table[If[k>Length[color],{0,0,0},color[[k]]],{k,2^size}]
];

(*--------------------------------------------------------*)
(*\:56fe\:50cf\:6570\:636e*)
(*\:8f93\:5165\:ff1adata\:ff08\:4e00\:7ef4\:5217\:8868\:ff0c\:6bcf\:4e2a\:5143\:7d20\:662f\:989c\:8272\:8868\:4e2d\:7684\:7d22\:5f15
        codeSize\:ff08\:6574\:6570\:ff0c\:989c\:8272\:8868\:7684\:4f4d\:6570\:ff0c1~7\:ff0c\:5f53\:4f4d\:6570\:7b49\:4e8e1\:65f6\:4f1a\:81ea\:52a8\:4f7f\:75282\:66ff\:4ee3\:4e4b\:ff09
 \:8f93\:51fa\:ff1a\:4e00\:7ef4\:5217\:8868*)
fImageData[data_,codeSize_]:=VLZWCompress`VLZW[data,codeSize];

(*--------------------------------------------------------*)
(*PlainTextExtension*)
fPlainTextExtension[text_,{left_:0,top_:0},{width_:100,height_:10},{cellWidth_:10,cellHeight_:10},{foregroundColorIndex_:0,backgroundColorIndex_:0}]:=Module[{
texts=StringPartition[text,UpTo[255]],
subBlocks
},
subBlocks=Table[{StringLength[t],ToCharacterCode[t]},{t,texts}](*~Join~{0}*);
Flatten[{
33,1,12,
Reverse@IntegerDigits[left,256,2],
Reverse@IntegerDigits[top,256,2],

Reverse@IntegerDigits[cellWidth StringLength[text],256,2],
Reverse@IntegerDigits[cellHeight,256,2],
cellWidth,
cellHeight,
foregroundColorIndex,
backgroundColorIndex,
subBlocks,
0
}]
];

(*--------------------------------------------------------*)
(*\:5e94\:7528\:63a7\:5236\:6269\:5c55 - \:91cd\:590d\:6b21\:6570*)
fApplicationExtension[repetitTimes_:Infinity]:=Module[{
times=If[repetitTimes==Infinity,{0,0},Inverse@IntegerDigits[repetitTimes,256,2]]
},
{
33,255,11,78,69,84,83,67,65,80,69,50,46,48,
3,1,
Sequence@@times,
0
}
];(*3,1,0,0,0-\:65e0\:9650\:6b21\:91cd\:590d\:ff0c\:5355\:6b21\:91cd\:590d3,1,1,0,0*)

(*--------------------------------------------------------*)
(*\:7ed3\:5c3e*)
cTrailer={59};

(*========================================================*)

End[ ]

EndPackage[ ]
