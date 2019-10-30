(* ::Package:: *)

(* ::Code::Initialization::Bold:: *)
(*\:53ef\:53d8\:957fLZW\:538b\:7f29\:7b97\:6cd5*)
(*\:4f5c\:8005\:ff1a\:674e\:5ba3\:ff08https://lixuan.xyz\:ff09*)
(*2019-10-29*)

BeginPackage["VLZWCompress`"]

VLZW::usage =
        "\:8f93\:5165\:ff1adata\:ff08\:4e00\:7ef4\:5217\:8868\:ff0c\:6bcf\:4e2a\:5143\:7d20\:662f\:989c\:8272\:8868\:4e2d\:7684\:7d22\:5f15
               codeSize\:ff08\:6574\:6570\:ff0c\:989c\:8272\:8868\:7684\:4f4d\:6570\:ff0c1~7\:ff0c\:5f53\:4f4d\:6570\:7b49\:4e8e1\:65f6\:4f1a\:81ea\:52a8\:4f7f\:75282\:66ff\:4ee3\:4e4b\:ff09
         \:8f93\:51fa\:ff1a\:4e00\:7ef4\:5217\:8868"

Begin["`Private`"]

(*--------------------------------------------------------*)
(*\:521d\:59cb\:5316\:5b57\:5178\:ff08\:989c\:8272\:8868\:ff09\:ff1a\:5b57\:7b26->\:7d22\:5f15*)
(*\:521d\:59cb\:5316\:5b57\:5178\:ff08\:989c\:8272\:8868\:ff09\:ff1a\:5b57\:7b26->\:7d22\:5f15*)
initDict[codeSize_]:=Module[{newCodeSize=Max[codeSize,2]},
<|
"dict"-><|{#}->#&/@Range[0,2^newCodeSize-1]|>,
"code_size"->newCodeSize,
"clear_code"->2^newCodeSize,
"end_code"->2^newCodeSize+1,
"current_index"->2^newCodeSize+2,
"current_code_length"->newCodeSize+1
|>
];

(*--------------------------------------------------------*)
(*\:5305\:88c5bit\:6d41*)
(*\:8f93\:5165\:ff1a\:4ece\:5de6\:5230\:53f3\:7684bit\:6d41\:ff0c\:5de6\:8fb9\:4e3a\:4f4e\:4f4d\:ff0c\:53f3\:8fb9\:4e3a\:9ad8\:4f4d*)
packBitDataToByte[bitDataLeftToRight_,maxLength_:255]:=Module[{
bytsStream,
bytsStreamPart255
},
bytsStream=FromDigits[Reverse@#,2]&/@Partition[Reverse[bitDataLeftToRight],8];(*\:8f6c\:6362\:4e3a\:5b57\:8282\:ff0c\:6700\:540e\:5269\:4f59\:4e0d\:8db38\:4f4d\:65f6\:4e5f\:80fd\:6b63\:5e38\:8ba1\:7b97*)
bytsStreamPart255={Length[#]}~Join~#&/@Partition[bytsStream,UpTo[255]];(*\:5207\:5206\:4e3a\:6700\:5927\:957f\:5ea6\:4e0d\:8d85\:8fc7255\:7684\:6570\:636e\:5757\:ff0c\:6bcf\:4e2a\:6570\:636e\:5757\:7684\:7b2c1\:4e2a\:5b57\:8282\:4e3a\:8be5\:6570\:636e\:5757\:7684\:957f\:5ea6*)
Flatten[bytsStreamPart255]~Join~{0}(*\:8ffd\:52a0 Block Terminator\:ff0c\:5e76\:8f93\:51fa\:7ed3\:679c*)
];


(* ::Code::Initialization::Bold:: *)
(*--------------------------------------------------------*)
(*\:53ef\:53d8\:957f\:7f16\:7801LZW\:538b\:7f29\:51fd\:6570*)
VLZW[data_,codeSize_]:=Module[{
dictInit=initDict[Max[codeSize,2]],
dict,
c=0,
p={},
pc={},
bitDataLeftToRight
},
dict=dictInit;
bitDataLeftToRight=IntegerDigits[dict["clear_code"],2,dict["current_code_length"]];

(*\:9010\:4e2a\:5904\:7406\:8f93\:5165\:4e2d\:7684\:5143\:7d20*)
Do[
c=da;
pc=Append[p,c];

If[KeyExistsQ[dict["dict"],pc],
(*\:5982\:679c\:5b57\:5178\:4e2d\:5b58\:5728pc\:ff0c\:8ffd\:52a0\:5143\:7d20c\:5230\:5217\:8868p\:4e2d*)
AppendTo[p,c];
,

(*\:5982\:679c\:5b57\:5178\:4e2d\:4e0d\:5b58\:5728pc\:ff0c\:8f93\:51fap\:7684\:7d22\:5f15\:ff0c\:5e76\:5c06pc\:6dfb\:52a0\:5230\:5b57\:5178\:4e2d\:ff0c\:4ee4p=c*)
bitDataLeftToRight=IntegerDigits[dict["dict"][p],2,dict["current_code_length"]]~Join~bitDataLeftToRight;
AssociateTo[dict["dict"],pc->dict["current_index"]++];
p={c};

(*\:4fee\:6539\:7f16\:7801\:957f\:5ea6*)
If[dict["current_index"]==2^dict["current_code_length"]+1,dict["current_code_length"]++];

(*\:5b57\:5178\:7d22\:5f15\:662f\:5426\:8fbe\:52304095*)
If[dict["current_index"]==4095,
bitDataLeftToRight=IntegerDigits[dict["clear_code"],2,dict["current_code_length"]]~Join~bitDataLeftToRight;
dict=dictInit;
];

];
(*======================*)
,{da,data}];

bitDataLeftToRight=IntegerDigits[dict["end_code"],2,dict["current_code_length"]]~Join~IntegerDigits[dict["dict"][p],2,dict["current_code_length"]]~Join~bitDataLeftToRight;

{Max[codeSize,2]}~Join~packBitDataToByte[bitDataLeftToRight]
];

End[ ]

EndPackage[ ]
