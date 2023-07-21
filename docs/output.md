# Outputs 

## Folder structure

Results are split by patient and therein by sample(s). Each sample folder contains the raw outputs from the various typing tools. Usable reports are stored under `Reports` in JSON and PDF format. 

### PDF Report

![](../images/report_example.png)

### JSON

The JSON format can be used to programmatically parse and transform the result data. An example follows below:

```
{
	"sample": "HG0001",
	"coverage": {
		"HLA-A": [{
			"exon": "HLA-A.ENST00000376809.1",
			"seq": "chr6",
			"start": 29942554,
			"stop": 29942626,
			"strand": "+",
			"mean_cov": 33
		}, {
			"exon": "HLA-A.ENST00000376809.2",
			"seq": "chr6",
			"start": 29942757,
			"stop": 29943026,
			"strand": "+",
			"mean_cov": 42
		}, {
			"exon": "HLA-A.ENST00000376809.3",
			"seq": "chr6",
			"start": 29943268,
			"stop": 29943543,
			"strand": "+",
			"mean_cov": 45
		}, {
			"exon": "HLA-A.ENST00000376809.4",
			"seq": "chr6",
			"start": 29944122,
			"stop": 29944397,
			"strand": "+",
			"mean_cov": 51
		}, {
			"exon": "HLA-A.ENST00000376809.5",
			"seq": "chr6",
			"start": 29944500,
			"stop": 29944616,
			"strand": "+",
			"mean_cov": 43
		}, {
			"exon": "HLA-A.ENST00000376809.6",
			"seq": "chr6",
			"start": 29945059,
			"stop": 29945091,
			"strand": "+",
			"mean_cov": 55
		}, {
			"exon": "HLA-A.ENST00000376809.7",
			"seq": "chr6",
			"start": 29945234,
			"stop": 29945281,
			"strand": "+",
			"mean_cov": 47
		}, {
			"exon": "HLA-A.ENST00000376809.8",
			"seq": "chr6",
			"start": 29945451,
			"stop": 29945455,
			"strand": "+",
			"mean_cov": 54
		}],
		"HLA-B": [{
			"exon": "HLA-B.ENST00000412585.1",
			"seq": "chr6",
			"start": 31357086,
			"stop": 31357158,
			"strand": "-",
			"mean_cov": 41
		}, {
			"exon": "HLA-B.ENST00000412585.2",
			"seq": "chr6",
			"start": 31356688,
			"stop": 31356957,
			"strand": "-",
			"mean_cov": 42
		}, {
			"exon": "HLA-B.ENST00000412585.3",
			"seq": "chr6",
			"start": 31356167,
			"stop": 31356442,
			"strand": "-",
			"mean_cov": 33
		}, {
			"exon": "HLA-B.ENST00000412585.4",
			"seq": "chr6",
			"start": 31355317,
			"stop": 31355592,
			"strand": "-",
			"mean_cov": 62
		}, {
			"exon": "HLA-B.ENST00000412585.5",
			"seq": "chr6",
			"start": 31355107,
			"stop": 31355223,
			"strand": "-",
			"mean_cov": 43
		}, {
			"exon": "HLA-B.ENST00000412585.6",
			"seq": "chr6",
			"start": 31354633,
			"stop": 31354665,
			"strand": "-",
			"mean_cov": 36
		}, {
			"exon": "HLA-B.ENST00000412585.7",
			"seq": "chr6",
			"start": 31354483,
			"stop": 31354526,
			"strand": "-",
			"mean_cov": 29
		}],
		"HLA-C": [{
			"exon": "HLA-C.ENST00000376228.1",
			"seq": "chr6",
			"start": 31271999,
			"stop": 31272071,
			"strand": "-",
			"mean_cov": 35
		}, {
			"exon": "HLA-C.ENST00000376228.2",
			"seq": "chr6",
			"start": 31271599,
			"stop": 31271868,
			"strand": "-",
			"mean_cov": 36
		}, {
			"exon": "HLA-C.ENST00000376228.3",
			"seq": "chr6",
			"start": 31271073,
			"stop": 31271348,
			"strand": "-",
			"mean_cov": 49
		}, {
			"exon": "HLA-C.ENST00000376228.4",
			"seq": "chr6",
			"start": 31270210,
			"stop": 31270485,
			"strand": "-",
			"mean_cov": 42
		}, {
			"exon": "HLA-C.ENST00000376228.5",
			"seq": "chr6",
			"start": 31269966,
			"stop": 31270085,
			"strand": "-",
			"mean_cov": 36
		}, {
			"exon": "HLA-C.ENST00000376228.6",
			"seq": "chr6",
			"start": 31269493,
			"stop": 31269525,
			"strand": "-",
			"mean_cov": 47
		}, {
			"exon": "HLA-C.ENST00000376228.7",
			"seq": "chr6",
			"start": 31269338,
			"stop": 31269385,
			"strand": "-",
			"mean_cov": 37
		}, {
			"exon": "HLA-C.ENST00000376228.8",
			"seq": "chr6",
			"start": 31269169,
			"stop": 31269173,
			"strand": "-",
			"mean_cov": 30
		}],
		"HLA-DRB1": [{
			"exon": "HLA-DRB1.ENST00000360004.1",
			"seq": "chr6",
			"start": 32589643,
			"stop": 32589742,
			"strand": "-",
			"mean_cov": 65
		}, {
			"exon": "HLA-DRB1.ENST00000360004.2",
			"seq": "chr6",
			"start": 32584109,
			"stop": 32584378,
			"strand": "-",
			"mean_cov": 47
		}, {
			"exon": "HLA-DRB1.ENST00000360004.3",
			"seq": "chr6",
			"start": 32581557,
			"stop": 32581838,
			"strand": "-",
			"mean_cov": 51
		}, {
			"exon": "HLA-DRB1.ENST00000360004.4",
			"seq": "chr6",
			"start": 32580746,
			"stop": 32580856,
			"strand": "-",
			"mean_cov": 79
		}, {
			"exon": "HLA-DRB1.ENST00000360004.5",
			"seq": "chr6",
			"start": 32580247,
			"stop": 32580270,
			"strand": "-",
			"mean_cov": 85
		}, {
			"exon": "HLA-DRB1.ENST00000360004.6",
			"seq": "chr6",
			"start": 32579091,
			"stop": 32579104,
			"strand": "-",
			"mean_cov": 73
		}],
		"HLA-DQA1": [{
			"exon": "HLA-DQA1.ENST00000343139.1",
			"seq": "chr6",
			"start": 32637459,
			"stop": 32637540,
			"strand": "+",
			"mean_cov": 48
		}, {
			"exon": "HLA-DQA1.ENST00000343139.2",
			"seq": "chr6",
			"start": 32641310,
			"stop": 32641558,
			"strand": "+",
			"mean_cov": 37
		}, {
			"exon": "HLA-DQA1.ENST00000343139.3",
			"seq": "chr6",
			"start": 32641972,
			"stop": 32642253,
			"strand": "+",
			"mean_cov": 44
		}, {
			"exon": "HLA-DQA1.ENST00000343139.4",
			"seq": "chr6",
			"start": 32642610,
			"stop": 32642764,
			"strand": "+",
			"mean_cov": 35
		}],
		"HLA-DQB1": [{
			"exon": "HLA-DQB1.ENST00000434651.1",
			"seq": "chr6",
			"start": 32666499,
			"stop": 32666607,
			"strand": "-",
			"mean_cov": 47
		}, {
			"exon": "HLA-DQB1.ENST00000434651.2",
			"seq": "chr6",
			"start": 32664798,
			"stop": 32665067,
			"strand": "-",
			"mean_cov": 30
		}, {
			"exon": "HLA-DQB1.ENST00000434651.3",
			"seq": "chr6",
			"start": 32661967,
			"stop": 32662248,
			"strand": "-",
			"mean_cov": 43
		}, {
			"exon": "HLA-DQB1.ENST00000434651.4",
			"seq": "chr6",
			"start": 32661347,
			"stop": 32661457,
			"strand": "-",
			"mean_cov": 44
		}, {
			"exon": "HLA-DQB1.ENST00000434651.5",
			"seq": "chr6",
			"start": 32660236,
			"stop": 32660249,
			"strand": "-",
			"mean_cov": 52
		}],
		"HLA-DPA1": [{
			"exon": "HLA-DPA1.ENST00000419277.2",
			"seq": "chr6",
			"start": 33073471,
			"stop": 33073570,
			"strand": "-",
			"mean_cov": 46
		}, {
			"exon": "HLA-DPA1.ENST00000419277.3",
			"seq": "chr6",
			"start": 33069641,
			"stop": 33069886,
			"strand": "-",
			"mean_cov": 60
		}, {
			"exon": "HLA-DPA1.ENST00000419277.4",
			"seq": "chr6",
			"start": 33069019,
			"stop": 33069300,
			"strand": "-",
			"mean_cov": 46
		}, {
			"exon": "HLA-DPA1.ENST00000419277.5",
			"seq": "chr6",
			"start": 33068650,
			"stop": 33068804,
			"strand": "-",
			"mean_cov": 56
		}],
		"HLA-DPB1": [{
			"exon": "HLA-DPB1.ENST00000418931.1",
			"seq": "chr6",
			"start": 33076042,
			"stop": 33076141,
			"strand": "+",
			"mean_cov": 69
		}, {
			"exon": "HLA-DPB1.ENST00000418931.2",
			"seq": "chr6",
			"start": 33080672,
			"stop": 33080935,
			"strand": "+",
			"mean_cov": 35
		}, {
			"exon": "HLA-DPB1.ENST00000418931.3",
			"seq": "chr6",
			"start": 33084950,
			"stop": 33085231,
			"strand": "+",
			"mean_cov": 55
		}, {
			"exon": "HLA-DPB1.ENST00000418931.4",
			"seq": "chr6",
			"start": 33085779,
			"stop": 33085889,
			"strand": "+",
			"mean_cov": 49
		}, {
			"exon": "HLA-DPB1.ENST00000418931.5",
			"seq": "chr6",
			"start": 33086219,
			"stop": 33086238,
			"strand": "+",
			"mean_cov": 67
		}]
	},
	"calls": {
		"A": {
			"HLA-HD": ["11:01", "01:01"],
			"xHLA": ["01:01", "11:01"],
			"HLAscan": ["01:01", "11:01"],
			"Optitype": ["01:01", "11:01"],
			"Hisat": ["11:01 (0.5131)", "01:01 (0.4869)"]
		},
		"B": {
			"HLA-HD": ["56:01", "08:01"],
			"xHLA": ["08:01", "56:01"],
			"HLAscan": ["08:01", "56:01"],
			"Optitype": ["08:01", "56:01"],
			"Hisat": ["08:01 (0.5101)", "56:01 (0.4898)"]
		},
		"C": {
			"HLA-HD": ["01:02", "07:01"],
			"xHLA": ["01:02", "07:01"],
			"HLAscan": ["07:01", "01:02"],
			"Optitype": ["01:02", "07:01"],
			"Hisat": ["07:01 (0.5046)", "01:02 (0.4954)"]
		},
		"DQB1": {
			"HLA-HD": ["02:01", "05:01"],
			"xHLA": ["02:01", "05:01"],
			"HLAscan": ["05:01", "02:01"],
			"Optitype": [],
			"Hisat": ["02:01 (0.5037)", "05:01 (0.4963)"]
		},
		"DRB1": {
			"HLA-HD": ["03:01", "01:01"],
			"xHLA": ["01:01", "03:01"],
			"HLAscan": ["03:01", "01:01"],
			"Optitype": [],
			"Hisat": ["01:01 (0.4159)", "03:01 (0.3597)"]
		},
		"DRB4": {
			"HLA-HD": [],
			"xHLA": [],
			"HLAscan": [],
			"Optitype": [],
			"Hisat": []
		},
		"DRB5": {
			"HLA-HD": [],
			"xHLA": [],
			"HLAscan": [],
			"Optitype": [],
			"Hisat": []
		},
		"DQA1": {
			"HLA-HD": ["01:01", "05:01"],
			"xHLA": [],
			"HLAscan": ["01:05", "05:01"],
			"Optitype": [],
			"Hisat": ["01:01 (0.5107)", "05:01 (0.4893)"]
		},
		"DRB3": {
			"HLA-HD": ["01:01"],
			"xHLA": [],
			"HLAscan": [],
			"Optitype": [],
			"Hisat": []
		},
		"DPA1": {
			"HLA-HD": ["01:03", "02:01"],
			"xHLA": [],
			"HLAscan": ["01:03", "02:01"],
			"Optitype": [],
			"Hisat": ["02:01 (0.5554)", "01:03 (0.4445)"]
		},
		"DPB1": {
			"HLA-HD": ["14:01", "04:01"],
			"xHLA": ["04:01", "14:01"],
			"HLAscan": ["04:01", "14:01"],
			"Optitype": [],
			"Hisat": ["14:01 (0.5354)", "04:01 (0.3981)"]
		}
	},
	"pipeline_version": "1.5rc1",
	"date": "18.07.2023",
	"commercial_tools": ["HLA-HD", "xHLA", "HLAscan"]
}

```