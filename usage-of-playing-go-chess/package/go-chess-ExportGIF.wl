(* ::Package:: *)

(*\:6839\:636e\:56f4\:68cb\:68cb\:8c31\:5bfc\:51faGIF*)
(*\:4f5c\:8005\:ff1a\:674e\:5ba3\:ff08https://lixuan.xyz\:ff09*)
(*2019-11-08*)

BeginPackage["goChess`"]

ExportGif::usage ="
\:3010\:8f93\:5165\:3011\:ff1a
\:3010\:8f93\:51fa\:3011\:ff1a
"

(*========================================================*)

Begin["`Private`"]
(*--------------------------------------------------------*)
(*\:9700\:8981\:5176\:5b833\:4e2a\:5305*)
ExportGif[savePath_,jsonData_,codeSize_,delayTime_:50]:=Module[{
goDict=jsonData["go_dict"],
stepStatus=jsonData["step_status"],
bdid=jsonData["bd_id"],
gifInfo,
pieceNormal,pieceSpecial,
imageBasic,imageBasicStar,imageBasicDemo,
globalColorTable,lzwData,
gifImageData
},
gifInfo=fGenGIFInfo[goDict];
pieceNormal=genGIFPiece[gifInfo];
pieceSpecial=genGIFChessboard[gifInfo];

imageBasic=fGenImageBasic[gifInfo];
imageBasicStar=Fold[ImageCompose[#1, pieceSpecial["img_cross_star"],fPieceRC2XY[#2,gifInfo],{Center,Center}]&,imageBasic,{{10,10},{4,4},{16,4},{4,16},{16,16}}];
imageBasicDemo=ImageCompose[imageBasicStar, pieceNormal["img_black_piece_current"],fPieceRC2XY[{3,3},gifInfo],{Center,Center}];
imageBasicDemo=ImageCompose[imageBasicDemo, pieceNormal["img_white_piece_current"],fPieceRC2XY[{5,5},gifInfo],{Center,Center}];
imageBasicDemo=ImageCompose[imageBasicDemo, pieceNormal["img_black_piece"],fPieceRC2XY[{7,7},gifInfo],{Center,Center}];
imageBasicDemo=ImageCompose[imageBasicDemo, pieceNormal["img_white_piece"],fPieceRC2XY[{9,9},gifInfo],{Center,Center}];

globalColorTable=fGlobalColorTable[imageBasicDemo,codeSize];

lzwData=<|
"base_image"->VLZWCompress`VLZW[fImage2Index[imageBasic,globalColorTable],codeSize],
"piece"-><|
"black"->VLZWCompress`VLZW[fImage2Index[pieceNormal["img_black_piece"],globalColorTable],codeSize],
"white"->VLZWCompress`VLZW[fImage2Index[pieceNormal["img_white_piece"],globalColorTable],codeSize],
"black_current"->VLZWCompress`VLZW[fImage2Index[pieceNormal["img_black_piece_current"],globalColorTable],codeSize],
"white_current"->VLZWCompress`VLZW[fImage2Index[pieceNormal["img_white_piece_current"],globalColorTable],codeSize],

"size"->(<|"width"->#1,"height"->#2|>&@@ImageDimensions[pieceNormal["img_black_piece"]])
|>,
"line"-><|
"inner_normal"->VLZWCompress`VLZW[fImage2Index[pieceSpecial["img_cross_4"],globalColorTable],codeSize],
"inner_star"->VLZWCompress`VLZW[fImage2Index[pieceSpecial["img_cross_star"],globalColorTable],codeSize],

"edge_left"->VLZWCompress`VLZW[fImage2Index[pieceSpecial["img_cross_3"][[3]],globalColorTable],codeSize],
"edge_top"->VLZWCompress`VLZW[fImage2Index[pieceSpecial["img_cross_3"][[2]],globalColorTable],codeSize],
"edge_right"->VLZWCompress`VLZW[fImage2Index[pieceSpecial["img_cross_3"][[1]],globalColorTable],codeSize],
"edge_bottom"->VLZWCompress`VLZW[fImage2Index[pieceSpecial["img_cross_3"][[4]],globalColorTable],codeSize],

"corner_rt"->VLZWCompress`VLZW[fImage2Index[pieceSpecial["img_cross_2"][[3]],globalColorTable],codeSize],
"corner_lt"->VLZWCompress`VLZW[fImage2Index[pieceSpecial["img_cross_2"][[4]],globalColorTable],codeSize],
"corner_lb"->VLZWCompress`VLZW[fImage2Index[pieceSpecial["img_cross_2"][[1]],globalColorTable],codeSize],
"corner_rb"->VLZWCompress`VLZW[fImage2Index[pieceSpecial["img_cross_2"][[2]],globalColorTable],codeSize],

"size"->(<|"width"->#1,"height"->#2|>&@@ImageDimensions[pieceSpecial["img_cross_4"]])
|>
|>;

(*\:751f\:6210GIF\:6570\:636e\:6d41*)
gifImageData=Flatten[{<|"position"-><|"left"->0,"top"->0|>,"delay_time"->delayTime,"frame_size"-><|"width"->gifInfo["gif_width"],"height"->gifInfo["gif_height"]|>,"data_lzw"->lzwData["base_image"]|>}~Join~Table[
{fAddPiece[step["add"],True,lzwData,gifInfo,delayTime],fSubPiece[step["sub"],lzwData,gifInfo],fAddPiece[step["add"],False,lzwData,gifInfo,delayTime]}
,{step,stepStatus}]];

GIFEncodeGCT`gif[savePath,<|"width"->gifInfo["gif_width"],"height"->gifInfo["gif_height"]|>,globalColorTable["global_color_table"],gifImageData,Infinity];
];


(*--------------------------------------------------------*)
(*\:751f\:6210\:5934\:90e8\:56fe\:50cf*)
fGenGIFInfo[goDict_]:=Module[{
goInfo,
imageHeader,
headerInfo,
headerWidth,headerHeight},
headerInfo=Column[{Style[goDict["info"]["\:6bd4\:8d5b\:540d\:79f0"],12,Bold,FontFamily->"\:5fae\:8f6f\:96c5\:9ed1"],
Style[goDict["info"]["\:6bd4\:8d5b\:65e5\:671f"],9,FontFamily->"\:5fae\:8f6f\:96c5\:9ed1"],

Row[Flatten@{
Style[goDict["info"]["\:6267\:9ed1\:68cb\:624b"],10,Bold,FontFamily->"\:5fae\:8f6f\:96c5\:9ed1"],
Style[#,10,FontFamily->"\:5fae\:8f6f\:96c5\:9ed1"]&/@{"[\:6267\:9ed1 ",goDict["info"]["\:9ed1\:68cb\:6bb5\:4f4d"],"]"},
Style["   vs   ",10,FontFamily->"\:5fae\:8f6f\:96c5\:9ed1"],
Style[goDict["info"]["\:6267\:767d\:68cb\:624b"],10,Bold,FontFamily->"\:5fae\:8f6f\:96c5\:9ed1"],
Style[#,10,FontFamily->"\:5fae\:8f6f\:96c5\:9ed1"]&/@{"[\:6267\:767d ",goDict["info"]["\:767d\:68cb\:6bb5\:4f4d"],"]"}
}],
Style[goDict["info"]["\:6bd4\:8d5b\:7ed3\:679c"],10,FontFamily->"\:5fae\:8f6f\:96c5\:9ed1"],
Style["lixuan.xyz",10,FontFamily->"\:5fae\:8f6f\:96c5\:9ed1"]
},Alignment->Center];

imageHeader=Rasterize[headerInfo,ImageResolution->100];
imageHeader=ColorConvert[imageHeader,"RGB"];
{headerWidth,headerHeight}=ImageDimensions[imageHeader]+10;

goInfo=<|
"line_thickness"->1,(*\:7ebf\:5bbd*)
"line_color"->0.8,(*\:7ebf\:7070\:5ea6*)
"space_thickness"->30,(*\:7a7a\:5bbd\:ff0c\:5373\:4e24\:6761\:7ebf\:4e4b\:95f4\:7684\:7a7a\:767d\:5bbd\:5ea6*)
"edge_thickness"->30,(*\:68cb\:76d8\:8fb9\:754c*)

"go_info_header"->imageHeader,(*[\:56fe\:7247]\:6807\:9898*)
"go_info_header_width"->headerWidth,(*\:6807\:9898\:5bbd\:5ea6*)
"go_info_header_height"->headerHeight(*\:6807\:9898\:5bbd\:5ea6*)
|>;
AssociateTo[goInfo,
{
"gif_width"->19goInfo["line_thickness"]+18goInfo["space_thickness"]+2goInfo["edge_thickness"],(*\:68cb\:76d8\:5bbd\:5ea6*)
"gif_height"->19goInfo["line_thickness"]+18goInfo["space_thickness"]+2goInfo["edge_thickness"]+headerHeight(*\:68cb\:76d8\:9ad8\:5ea6*)
}]
];

(*--------------------------------------------------------*)
(*\:751f\:6210\:666e\:901a\:68cb\:5b50*)
genGIFPiece[gifInfo_]:=Module[{
pieceSize=Round[0.85(gifInfo["space_thickness"]+gifInfo["line_thickness"])]
},
<|
(*\:666e\:901a\:68cb\:5b50*)
"img_black_piece"->ColorConvert[Rasterize[Graphics[{GrayLevel[0.3],EdgeForm[Directive[AbsoluteThickness[2],Black]],Disk[]}],ImageSize->pieceSize],"RGB"],
"img_white_piece"->ColorConvert[Rasterize[Graphics[{GrayLevel[0.9],EdgeForm[Directive[AbsoluteThickness[2],Black]],Disk[]}],ImageSize->pieceSize],"RGB"],

(*\:5f53\:524d\:6b65\:68cb\:5b50*)
"img_black_piece_current"->ColorConvert[Rasterize[Graphics[{GrayLevel[0.3],EdgeForm[Directive[AbsoluteThickness[2],Black]],Disk[],EdgeForm[],Red,Disk[{0,0},0.5]}],ImageSize->pieceSize],"RGB"],
"img_white_piece_current"->ColorConvert[Rasterize[Graphics[{GrayLevel[0.9],EdgeForm[Directive[AbsoluteThickness[2],Black]],Disk[],EdgeForm[],Red,Disk[{0,0},0.5]}],ImageSize->pieceSize],"RGB"]
|>
];
(*\:751f\:6210\:7279\:6b8a\:68cb\:5b50\:ff1a\:68cb\:76d8\:4e0a\:7684\:7ebf \[LongDash]\[LongDash] \:7279\:6b8a\:7684\:68cb\:5b50 \[LongDash]\[LongDash] \:7528\:4e8e\:63d0\:5b50\:65f6\:8986\:76d6\:539f\:68cb\:5b50*)
genGIFChessboard[gifInfo_]:=Module[{
imgRC={gifInfo["space_thickness"]+gifInfo["line_thickness"],gifInfo["space_thickness"]+gifInfo["line_thickness"]},
st=gifInfo["space_thickness"],
lt=gifInfo["line_thickness"],
lineColor=gifInfo["line_color"],
semiLineTop,
semiLineBottom,
semiLineLeft,
semiLineRight,
centerPoint,
centerStar,
cross4
},
centerStar=SparseArray[{{i_,j_}/;(Abs[i-st/2-lt]+Abs[j-st/2-lt]<6)->0},imgRC,1];
centerPoint=SparseArray[{{i_,j_}/;(Abs[i-st/2-lt]<lt&&Abs[j-st/2-lt]<lt)->0},imgRC,1];
semiLineLeft=SparseArray[{{i_,j_}/;(st/2<i<=st/2+lt&&j<st/2+lt)->0},imgRC,1];
semiLineTop=Transpose[semiLineLeft];
semiLineRight=SparseArray[{{i_,j_}/;(st/2<i<=st/2+lt&&st/2+lt<j)->0},imgRC,1];
semiLineBottom=Transpose[semiLineRight];

<|
"img_cross_4"->ColorConvert[Image[Normal[centerPoint semiLineLeft semiLineTop semiLineRight semiLineBottom]/.(0->lineColor)],"RGB"],
"img_cross_star"->ColorConvert[Image[Normal[centerStar semiLineLeft semiLineTop semiLineRight semiLineBottom]/.(0->lineColor)],"RGB"],
"img_cross_3"->{
ColorConvert[Image[Normal[centerPoint semiLineLeft semiLineTop semiLineBottom]/.(0->lineColor)],"RGB"],
ColorConvert[Image[Normal[centerPoint semiLineLeft semiLineRight semiLineBottom]/.(0->lineColor)],"RGB"],
ColorConvert[Image[Normal[centerPoint semiLineTop semiLineRight semiLineBottom]/.(0->lineColor)],"RGB"],
ColorConvert[Image[Normal[centerPoint semiLineLeft semiLineTop semiLineRight]/.(0->lineColor)],"RGB"]
},
"img_cross_2"->{
ColorConvert[Image[Normal[centerPoint semiLineTop semiLineRight]/.(0->lineColor)],"RGB"],
ColorConvert[Image[Normal[centerPoint semiLineLeft semiLineTop]/.(0->lineColor)],"RGB"],
ColorConvert[Image[Normal[centerPoint semiLineLeft semiLineBottom]/.(0->lineColor)],"RGB"],
ColorConvert[Image[Normal[centerPoint semiLineRight semiLineBottom]/.(0->lineColor)],"RGB"]
}
|>
];
(*--------------------------------------------------------*)
(*\:5750\:6807\:8f6c\:6362\:ff1a\:68cb\:76d8\:4e0a\:7684\:884c\:5217\:ff0c\:8f6c\:6210Mma\:4e2dImageCompose\:7684xy*)
(*\:8f93\:5165
{\:884c_\:4ece\:4e0a\:65701~19\:ff0c\:5217_\:4ece\:5de6\:65701~19},gifInfo
*)
fPieceRC2XY[{r_,c_},gifInfo_]:=Module[{
stepLength=gifInfo["line_thickness"]+gifInfo["space_thickness"],
rc
},
(*\:8f6c\:5316\:4e3a\:56fe\:50cf\:4e2d\:7684\:884c\:6570\:5217\:6570*)
rc={gifInfo["go_info_header_height"]+(r-1)stepLength,(c-1)stepLength}+gifInfo["edge_thickness"];
(**)
{rc[[2]],gifInfo["gif_height"]-rc[[1]]-1}
];

(*\:5750\:6807\:8f6c\:6362\:ff1a\:68cb\:76d8\:4e0a\:7684\:884c\:5217\:ff0c\:8f6c\:6210GIF\:4e2d\:7684{left,top}*)
(*\:8f93\:5165
{\:884c_\:4ece\:4e0a\:65701~19\:ff0c\:5217_\:4ece\:5de6\:65701~19},gifInfo
*)
fPieceRC2gifLT[{r_,c_},gifInfo_]:=Module[{
stepLength=gifInfo["line_thickness"]+gifInfo["space_thickness"]
},
(*\:8f6c\:5316\:4e3a\:56fe\:50cf\:4e2d\:7684\:884c\:6570\:5217\:6570*)
{(c-1)stepLength,gifInfo["go_info_header_height"]+(r-1)stepLength}+gifInfo["edge_thickness"]-1
];
(*--------------------------------------------------------*)
(*\:751f\:6210\:80cc\:666f\:56fe\:50cf*)
fGenImageBasic[gifInfo_]:=Module[{
rangeStep=gifInfo["line_thickness"]+gifInfo["space_thickness"],
rangeAll=18(gifInfo["line_thickness"]+gifInfo["space_thickness"])+gifInfo["line_thickness"],
points=Flatten@Table[Range[gifInfo["line_thickness"]]+k (gifInfo["line_thickness"]+gifInfo["space_thickness"]),{k,0,18}],
rows,cols,matrix,
chessBoard,
pieceSpecial=genGIFChessboard[gifInfo]
},
rows=Flatten@Outer[{#1,#2}->0.8&,points,Range[rangeAll]];
cols=Flatten@Outer[{#1,#2}->0.8&,Range[rangeAll],points];
matrix=SparseArray[rows~Join~cols,{rangeAll,rangeAll},1];

Image@ArrayPad[matrix,{{gifInfo["go_info_header_height"]+gifInfo["edge_thickness"],gifInfo["edge_thickness"]},{gifInfo["edge_thickness"],gifInfo["edge_thickness"]}},1];

chessBoard=ImageCompose[
(*\:68cb\:76d8\:65b9\:683c*)
Image@ArrayPad[matrix,{{gifInfo["go_info_header_height"]+gifInfo["edge_thickness"],gifInfo["edge_thickness"]},{gifInfo["edge_thickness"],gifInfo["edge_thickness"]}},1], 
(*\:6807\:9898*)
gifInfo["go_info_header"],
{Center,Top},{Center,Top}];

Fold[ImageCompose[#1, pieceSpecial["img_cross_star"],fPieceRC2XY[#2,gifInfo],{Center,Center}]&,chessBoard,{{10,10},{4,4},{16,4},{4,16},{16,16}}]

];

(*--------------------------------------------------------*)
(*\:5168\:5c40\:989c\:8272\:8868 - \:68cb\:5b50\:3001\:68cb\:76d8\:3001\:6807\:9898*)
fGlobalColorTable[imageDemo_,codeSize_]:=Module[{
image=ColorQuantize[imageDemo,2^codeSize,Method->"MedianCut"],
gct
},
gct=Union[Flatten[ImageData[image,"Byte"],1]];

<|
"global_color_table"->gct,
"global_color_table_index"-><|MapIndexed[#1->#2[[1]]-1&,gct]|>
|>
];

(*\:56fe\:50cf\:8f6c\:7d22\:5f15 \[LeftArrow] \:6839\:636e\:5168\:5c40\:989c\:8272\:8868*)
fImage2Index[image_,colorTable_]:=Module[{imageData=Flatten[ImageData[image,"Byte"],1]},
Lookup[colorTable["global_color_table_index"],Key[#],Lookup[colorTable["global_color_table_index"],Key[Nearest[colorTable["global_color_table"],#,1][[1]]],0]]&/@imageData
];
(*--------------------------------------------------------*)
(*\:843d\:5b50*)
fAddPiece[add_,current_,lzwData_,gifInfo_,delayTime_:50]:=Table[<|
"id"->a["id"],
"position"->(<|"left"->#1-Floor[lzwData["piece"]["size"]["width"]/2]+1,"top"->#2-Floor[lzwData["piece"]["size"]["height"]/2]+1|>&@@fPieceRC2gifLT[a["position_matirx"],gifInfo]),
"delay_time"->delayTime,
"frame_size"->lzwData["piece"]["size"],
"data_lzw"->If[a["color"]=="B",
If[current,lzwData["piece"]["black_current"],lzwData["piece"]["black"]],
If[current,lzwData["piece"]["white_current"],lzwData["piece"]["white"]]
]
|>,{a,add}];

(*\:63d0\:5b50*)
fSubPiece[sub_,lzwData_,gifInfo_]:=Table[<|
"id"->s["id"],
"position"-><|"left"->#1-Floor[lzwData["line"]["size"]["width"]/2]+1,"top"->#2-Floor[lzwData["line"]["size"]["height"]/2]+1|>&@@fPieceRC2gifLT[s["position_matirx"],gifInfo],
"delay_time"->0,
"frame_size"->lzwData["line"]["size"],
"data_lzw"->Piecewise[{
{lzwData["line"]["corner_rt"],s["position_matirx"]=={1,19}},
{lzwData["line"]["corner_lt"],s["position_matirx"]=={1,1}},
{lzwData["line"]["corner_lb"],s["position_matirx"]=={19,1}},
{lzwData["line"]["corner_rb"],s["position_matirx"]=={19,19}},

{lzwData["line"]["edge_left"],s["position_matirx"][[2]]==1},
{lzwData["line"]["edge_top"],s["position_matirx"][[1]]==1},
{lzwData["line"]["edge_right"],s["position_matirx"][[2]]==19},
{lzwData["line"]["edge_bottom"],s["position_matirx"][[1]]==19},

{lzwData["line"]["inner_star"],MemberQ[{"JJ","DD","PD","DP","PP"},s["position_letter"]]}
},
lzwData["line"]["inner_normal"]]
|>,{s,sub}];

End[]
EndPackage[]
