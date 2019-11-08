(* ::Package:: *)

(*GIF\:7f16\:7801*)
(*\:4ec5\:4f7f\:7528\:5168\:5c40\:989c\:8272\:8868*)
(*\:4f5c\:8005\:ff1a\:674e\:5ba3\:ff08https://lixuan.xyz\:ff09*)
(*2019-10-29*)

BeginPackage["goChess`"]

SGFExportJSON::usage="
\:8f93\:5165\:ff1asavePath_String, dbid_String, sgf_String
\:8f93\:51fa\:ff1asavePath
"
fSGF2Dict::usage="
\:8f93\:5165\:ff1asgf_String
\:8f93\:51fa\:ff1a<||>
"
(*========================================================*)

Begin["`Private`"]

(*--------------------------------------------------------*)
SGFExportJSON[savePath_String,dbid_String,sgf_String]:=Module[{
goDict=fSGF2Dict[sgf],
initOldData,
checkerboardList={},
g,stepStatus
},
(*\:521d\:59cb\:72b6\:6001*)
initOldData=<|
"id_graph"->Graph[{}],
"manual_data_all"->goDict["data"],
"pieces_on_checkerboard"->{}
|>;
Do[
g=fGoGraph[If[k==1,initOldData,g],goDict["data"][[k]]];
AppendTo[checkerboardList,g["id_graph"]];
,{k,Length[goDict["data"]]}
];

stepStatus=Table[
If[k==1,
<|
"id"->k,
"add"->goDict["data"]/@VertexList[checkerboardList[[k]]],
"sub"->{}|>
,
<|
"id"->k,
"add"->goDict["data"]/@Complement[VertexList[checkerboardList[[k]]],VertexList[checkerboardList[[k-1]]]],
"sub"->goDict["data"]/@Complement[VertexList[checkerboardList[[k-1]]],VertexList[checkerboardList[[k]]]]|>
]
,{k,Length[checkerboardList]}];

Developer`WriteRawJSONFile[savePath,<|
"step_status"->stepStatus,
"db_id"->dbid,
"go_dict"->AssociateTo[goDict,{"data"->0}],
"sgf_string"->sgf
|>,"Compact"->1]
];
(*--------------------------------------------------------*)
(*\:8f93\:5165\:ff1a\:4e00\:76d8\:5b57\:7b26\:4e32\:683c\:5f0f\:7684SGF\:56f4\:68cb\:6570\:636e*)
(*\:8f93\:51fa\:ff1a\:6bd4\:8d5b\:4fe1\:606f info\:ff0c\:68cb\:8c31\:4fe1\:606f data\:ff0c\:4ee5\:53ca\:4e00\:4e9b\:5e38\:91cf db_id, letter_upper_case, letter_lower_case, position_around, position_to_xy, position_to_rc *)
fSGF2Dict[sgf_String]:=Module[{
goInfo=<||>,data,
id=0,

(*\:4f4d\:7f6e\:7528\:5230\:7684\:5b57\:6bcd\:ff0c\:53ca\:76f8\:90bb\:5b57\:6bcd*)
dicLetter=<|{"A"->{"B"}}~Join~(#2->{#1,#3}&@@@Partition[CharacterRange["A","S"],3,1])~Join~{"S"->{"R"}}|>,

(*\:4f4d\:7f6e\:ff0c\:53ca\:90bb\:4f4d*)
dicPositionAround,

(*\:4f4d\:7f6e\:ff0c\:5bf9\:5e94\:7684\:6570\:5b57\:4f4d\:7f6e\:ff0cpd\:ff0c\:5148\:5217\:540e\:884c\:ff0c\:65b9\:4fbfGraphics\:7684xy\:5750\:6807\:7ed8\:56fe\:ff0c\:77e9\:9635\:7ed8\:56fe\:9700\:8981\:8f6c\:6362\:5750\:6807*)
dicPositionToXY,

(*\:4f4d\:7f6e\:ff0c\:5bf9\:5e94\:7684\:6570\:5b57\:4f4d\:7f6e\:ff0cpd\:ff0c\:5148\:884c\:540e\:5217\:ff0c\:76f4\:63a5\:5bf9\:5e94\:77e9\:9635\:7684\:884c\:5217*)
dicPositionToRC

},
dicPositionAround=<|
Flatten@Outer[
#1<>#2->Flatten[{Thread[#1->dicLetter[#2]],Thread[dicLetter[#1]->#2]}/.Rule->StringJoin]&,
Keys[dicLetter],
Keys[dicLetter]
]
|>;

dicPositionToXY=<|#->{0,20}-{-1,1}(ToCharacterCode[#]-64)&/@Keys[dicPositionAround]|>;

dicPositionToRC=<|#->RotateLeft@ToCharacterCode[#]-64&/@Keys[dicPositionAround]|>;

AssociateTo[goInfo,<|"letter_upper_case"->dicLetter|>];
AssociateTo[goInfo,<|"letter_lower_case"->dicLetter|>];
AssociateTo[goInfo,<|"position_around"->dicPositionAround|>];
AssociateTo[goInfo,<|"position_to_xy"->dicPositionToXY|>];
AssociateTo[goInfo,<|"position_to_rc"->dicPositionToXY|>];


AssociateTo[goInfo,<|
"info"-><|
"\:6267\:9ed1\:68cb\:624b"->StringCases[sgf,RegularExpression["PB\\[([^]]+)\\]"]:>"$1"][[1]],
"\:9ed1\:68cb\:6bb5\:4f4d"->If[StringCases[sgf,RegularExpression["BR\\[([^]]+)\\]"]:>"$1"]=={},"\:65e0\:6bb5",StringCases[sgf,RegularExpression["BR\\[([^]]+)\\]"]:>"$1"][[1]]],
"\:6267\:767d\:68cb\:624b"->StringCases[sgf,RegularExpression["PW\\[([^]]+)\\]"]:>"$1"][[1]],
"\:767d\:68cb\:6bb5\:4f4d"->If[StringCases[sgf,RegularExpression["WR\\[([^]]+)\\]"]:>"$1"]=={},"\:65e0\:6bb5",StringCases[sgf,RegularExpression["WR\\[([^]]+)\\]"]:>"$1"][[1]]],

"\:6bd4\:8d5b\:7ed3\:679c"->StringCases[sgf,RegularExpression["RE\\[([^]]+)\\]"]:>"$1"][[1]],
"\:6bd4\:8d5b\:65e5\:671f"->StringCases[sgf,RegularExpression["RD\\[([^]]+)\\]"]:>"$1"][[1]],
"\:6bd4\:8d5b\:540d\:79f0"->StringCases[sgf,RegularExpression["TE\\[([^]]+)\\]"]:>"$1"][[1]]
|>
|>];

data=<|StringCases[sgf,RegularExpression[";(\\w)\\[(\\w{2})\\]"]:>(++id-><|
"id"->id,(*\:6b65\:6570*)
"color"->ToUpperCase["$1"],
"position_letter"->ToUpperCase["$2"],
"position_xy"->Lookup[dicPositionToXY,ToUpperCase["$2"],{0,0}],(*\:505c\:7740\:ff0c{0,0}*)
"position_matirx"->Lookup[dicPositionToRC,ToUpperCase["$2"],{0,0}],(*\:505c\:7740\:ff0c{0,0}*)
"group_id"->0,
"breath_left"->Length[Lookup[dicPositionAround,ToUpperCase["$2"],{}]],(*\:505c\:7740\:ff0c0*)
"around_letter"->Lookup[dicPositionAround,ToUpperCase["$2"],{}](*\:505c\:7740\:ff0c{}*)
|>)]|>;
data=DeleteCases[data,x_/;x["position_xy"]=={0,0}];
AssociateTo[goInfo,<|"data"->data|>];

goInfo
];

(*--------------------------------------------------------*)
(*\:8f93\:5165\:ff1a\:68cb\:76d8\:539f\:72b6\:6001\:ff0c\:5f53\:524d\:843d\:5b50\:3002\:8be6\:60c5\:53c2\:89c1\:540e\:9762\:7684\:6d4b\:8bd5\:90e8\:5206*)
(*\:8f93\:51fa[graph]\:ff1a\:6bcf\:6b65\:843d\:5b50\:540e\:7684\:68cb\:76d8\:72b6\:6001*)
fGoGraph[oldData_,piece_]:=Module[{
newData=oldData,
(*\:68cb\:76d8\:4e0a\:7684\:68cb\:5b50\:ff0c\:542b\:65b0\:5b50*)
piecesOnCheckerboard=oldData["pieces_on_checkerboard"]~Join~{piece},
piecesOnCheckerboardLetter=#["position_letter"]&/@oldData["pieces_on_checkerboard"]~Join~{piece},
newIDGraph=oldData["id_graph"],

pieceID=piece["id"],
pieceAroud=piece["around_letter"],
pieceColor=piece["color"],

sameColorPieces,anotherColorPieces,subIDGraph,groups,flag
},
(* ==== \:5728IDGraph\:4e2d\:589e\:52a0\:68cb\:5b50 ==== *)
(*\:68cb\:76d8\:4e0a\:ff0c\:8be5\:5b50\:5468\:8fb9\:7684\:540c\:8272\:68cb\:5b50*)
sameColorPieces=Select[piecesOnCheckerboard,MemberQ[pieceAroud,#["position_letter"]]&&#["color"]==pieceColor&];
If[Length[sameColorPieces]>0,
(*\:5411IDGraph\:4e2d\:589e\:52a0\:68cb\:5b50: \:5468\:8fb9\:6709\:8fde\:63a5\:7684\:540c\:8272\:68cb\:5b50*)
newIDGraph=EdgeAdd[newIDGraph,piece["id"]\[UndirectedEdge]#["id"]&/@sameColorPieces],
(*\:5411IDGraph\:4e2d\:589e\:52a0\:68cb\:5b50: \:5468\:8fb9\:6ca1\:6709\:8fde\:63a5\:7684\:540c\:8272\:68cb\:5b50*)
newIDGraph=VertexAdd[newIDGraph,piece["id"]]
];


(* ==== \:5728IDGraph\:4e2d\:51cf\:5c11\:68cb\:5b50\:ff1a\:63d0\:5bf9\:7acb\:989c\:8272\:7684\:68cb\:5b50\:ff08\:4e0d\:5141\:8bb8\:81ea\:6740\:ff09 ==== *)
(*\:68cb\:76d8\:4e0a\:ff0c\:8be5\:5b50\:5468\:8fb9\:7684\:5f02\:8272\:68cb\:5b50*)
anotherColorPieces=Select[piecesOnCheckerboard,MemberQ[pieceAroud,#["position_letter"]]&&#["color"]!=pieceColor&];
If[Length[anotherColorPieces]>0,
(*\:6240\:6709\:6d89\:53ca\:5230\:7684\:5f02\:8272\:68cb\:5b50*)
subIDGraph=Subgraph[newIDGraph,VertexComponent[newIDGraph,#["id"]&/@ anotherColorPieces]];
groups=ConnectedComponents[subIDGraph];
Do[
flag="\:63d0\:5b50";
Do[
(* \:6d3b\:68cb\:6761\:4ef6\:ff1a\:4e0e\:8be5\:5b50\:8fde\:6210\:4e00\:5757\:7684\:540c\:8272\:68cb\:5b50\:4e2d\:81f3\:5c11\:6709\:9897\:5b50\:ff0c\:5176\:5468\:8fb9\:5b58\:5728\:7a7a\:4f4d\:ff0c\:5373\:5176\:5468\:8fb9\:76844\:4e2a\:4f4d\:7f6e\:4e2d\:81f3\:5c11\:8868\:4e00\:4e2a\:4e0d\:5728 piecesOnCheckerboard \:4e2d *)
If[SubsetQ[piecesOnCheckerboardLetter,oldData["manual_data_all"][id]["around_letter"]]!=True,flag="\:6d3b\:68cb";Break[]];
,{id,group}];
If[flag=="\:63d0\:5b50",newIDGraph=VertexDelete[newIDGraph,group]];
,{group,groups}]
];

(*\:8f93\:51fa*)
AssociateTo[newData,{
"id_graph"->newIDGraph,
"pieces_on_checkerboard"->Select[piecesOnCheckerboard,MemberQ[VertexList[newIDGraph],#["id"]]&]
}]
];
End[ ]
EndPackage[ ]



