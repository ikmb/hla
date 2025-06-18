# Common issues

## I cannot run HLA-HD?!

Well, no you can't, if you haven't configured the IKMB "custom" environment modules. HLA-HD is locally installed on MedCluster only and, due to licensing restrictions, cannot be containerized. 
You will need to include the custom IKMB module system into your bash profile ($HOME/.bash_profile):

```
export MODULEPATH=$MODULEPATH:/work_beegfs/ikmb_repository/modules/Bioinfo
```

Afterwards, either `source` the bash profile again, or just start a new shell session. 

