#!/bin/bash

read -p "Enter Exported Filename: " file
read -p "Enter Month and year (example: jan2020): " mon
echo $mon >> new-message-id-2.txt
allmessages=$(cat $file)
wget https://cloud.google.com/healthcare/docs/resources/hl7v2-sample.json
mkdir null-messages
for q in $allmessages
do
        qq=$(echo $q | jq '.data' | rev | cut -c 2- | rev | cut -c 2-)
        qqq=$(echo $q | jq '.name'  | cut -d "/" -f 10 | rev | cut -c 2- | rev)
        echo $qq > 1datapart.txt

        echo "Decoding data part..."
        base64 --decode 1datapart.txt > 1decode.txt

        echo ""
        echo "Modifying Data field..."

        sed -i -e "s/\r/\n/g" 1decode.txt

###SCH###
        SCHSEG=$(cat 1decode.txt | grep "^SCH" | wc -l)
        SCH3=$(cat 1decode.txt | grep "^SCH" | cut -d '|' -f 3 | cut -d '^' -f 1 | wc -w)
        if [ "$SCH3" == "1" ] && [ "$SCHSEG" == "1" ]
        then
                SCH3U=$(cat 1decode.txt | grep "^SCH" | cut -d '|' -f 3 | cut -d '^' -f 1)
                sed -i -e "/SCH/s/$SCH3U/00000000000/" 1decode.txt
        fi

        SCH11=$(cat 1decode.txt | grep "^SCH" | cut -d '|' -f 12 | cut -d '^' -f 4 | wc -w)
        if [ "$SCH11" == "1" ] && [ "$SCHSEG" == "1" ]
        then
                SCH11U=$(cat 1decode.txt | grep "^SCH" | cut -d '|' -f 12 | cut -d '^' -f 4)
                sed -i -e "/SCH/s/$SCH11U/ddmmyyyy/" 1decode.txt
        fi
###SCH###

###MSH###
        MSHSEG=$(cat 1decode.txt | grep "^MSH" | wc -l)
        MSH3=$(cat 1decode.txt | grep "^MSH" | cut -d '|' -f 4 | cut -d '^' -f 1 | wc -w)
        MSH3D=$(cat 1decode.txt | grep "^MSH" | cut -d '|' -f 4 | cut -d '^' -f 1)

        case $MSH3D in
                NKCH)
                        if [ "$MSH3" == "1" ] && [ "$MSHSEG" == "1" ]
                        then
                                MSH3U=$(cat 1decode.txt | grep "^MSH" | cut -d '|' -f 4 | cut -d '^' -f 1)
                                sed -i -e "/MSH/s/$MSH3U/E1001XX/g" 1decode.txt
                        fi
                ;;

                CCHMC)
                        if [ "$MSH3" == "1" ] && [ "$MSHSEG" == "1" ]
                        then
                                MSH3U=$(cat 1decode.txt | grep "^MSH" | cut -d '|' -f 4 | cut -d '^' -f 1)
                                sed -i -e "/MSH/s/$MSH3U/E1002XX/g" 1decode.txt
                        fi
                ;;

                ECH)
                        if [ "$MSH3" == "1" ] && [ "$MSHSEG" == "1" ]
                        then
                                MSH3U=$(cat 1decode.txt | grep "^MSH" | cut -d '|' -f 4 | cut -d '^' -f 1)
                                sed -i -e "/MSH/s/$MSH3U/E1003XX/g" 1decode.txt
                        fi
                ;;

                UAB)
                        if [ "$MSH3" == "1" ] && [ "$MSHSEG" == "1" ]
                        then
                                MSH3U=$(cat 1decode.txt | grep "^MSH" | cut -d '|' -f 4 | cut -d '^' -f 1)
                                sed -i -e "/MSH/s/$MSH3U/E1004XX/g" 1decode.txt
                        fi
                ;;

                NEM)
                        if [ "$MSH3" == "1" ] && [ "$MSHSEG" == "1" ]
                        then
                                MSH3U=$(cat 1decode.txt | grep "^MSH" | cut -d '|' -f 4 | cut -d '^' -f 1)
                                sed -i -e "/MSH/s/$MSH3U/E1005XX/g" 1decode.txt
                        fi
                ;;

                UCSF)
                        if [ "$MSH3" == "1" ] && [ "$MSHSEG" == "1" ]
                        then
                                MSH3U=$(cat 1decode.txt | grep "^MSH" | cut -d '|' -f 4 | cut -d '^' -f 1)
                                sed -i -e "/MSH/s/$MSH3U/E1006XX/g" 1decode.txt
                        fi
                ;;

                NGHS)
                        if [ "$MSH3" == "1" ] && [ "$MSHSEG" == "1" ]
                        then
                                MSH3U=$(cat 1decode.txt | grep "^MSH" | cut -d '|' -f 4 | cut -d '^' -f 1)
                                sed -i -e "/MSH/s/$MSH3U/E1007XX/g" 1decode.txt
                        fi
                ;;
                
                BSMH)
                        if [ "$MSH3" == "1" ] && [ "$MSHSEG" == "1" ]
                        then
                                MSH3U=$(cat 1decode.txt | grep "^MSH" | cut -d '|' -f 4 | cut -d '^' -f 1)
                                sed -i -e "/MSH/s/$MSH3U/E1008XX/g" 1decode.txt
                        fi
                ;;

                INOVA)
                        if [ "$MSH3" == "1" ] && [ "$MSHSEG" == "1" ]
                        then
                                MSH3U=$(cat 1decode.txt | grep "^MSH" | cut -d '|' -f 4 | cut -d '^' -f 1)
                                sed -i -e "/MSH/s/$MSH3U/E1009XX/g" 1decode.txt
                        fi
                ;;

                UMH)
                        if [ "$MSH3" == "1" ] && [ "$MSHSEG" == "1" ]
                        then
                                MSH3U=$(cat 1decode.txt | grep "^MSH" | cut -d '|' -f 4 | cut -d '^' -f 1)
                                sed -i -e "/MSH/s/$MSH3U/E1010XX/g" 1decode.txt
                        fi
                ;;

                RUMC)
                        if [ "$MSH3" == "1" ] && [ "$MSHSEG" == "1" ]
                        then
                                MSH3U=$(cat 1decode.txt | grep "^MSH" | cut -d '|' -f 4 | cut -d '^' -f 1)
                                sed -i -e "/MSH/s/$MSH3U/E1011XX/g" 1decode.txt
                        fi
                ;;

                *)
                        if [ "$MSH3" == "1" ] && [ "$MSHSEG" == "1" ]
                        then
                                MSH3U=$(cat 1decode.txt | grep "^MSH" | cut -d '|' -f 4 | cut -d '^' -f 1)
                                sed -i -e "/MSH/s/$MSH3U/E1008XX$MSH3U/g" 1decode.txt
                        fi
                ;;
                
        esac



        MSH5=$(cat 1decode.txt | grep "^MSH" | cut -d "|" -f 5 | cut -d '^' -f 1 | wc -w)

        if [ "$MSHSEG" == "1" ] && [ "$MSH5" != "0" ]
        then
                MSH5U=$(cat 1decode.txt | grep "^MSH" | cut -d "|" -f 5 | cut -d '^' -f 1)
                sed -i -e "/MSH/s/$MSH5U/F1000ZZ/g" 1decode.txt          ## F1000ZZ=Readyset
        fi



        MSH21=$(cat 1decode.txt | grep "^MSH" | cut -d '|' -f 22 | cut -d '^' -f 1 | wc -w)
        MSH21D=$(cat 1decode.txt | grep "^MSH" | cut -d '|' -f 22 | cut -d '^' -f 1)

        msh () {
                case $MSH21D in
                        UMiamiHealth|UMH)
                                if [ "$MSH21" == "1" ] && [ "$MSHSEG" == "1" ]
                                then
                                        MSH21U=$(cat 1decode.txt | grep "^MSH" | cut -d '|' -f 22 | cut -d '^' -f 1)
                                        sed -i -e "/MSH/s/$MSH21U/Q1010YY/g" 1decode.txt
                                fi
                        ;;

                        BSMH)
                                if [ "$MSH21" == "1" ] && [ "$MSHSEG" == "1" ]
                                then
                                        MSH21U=$(cat 1decode.txt | grep "^MSH" | cut -d '|' -f 22 | cut -d '^' -f 1)
                                        sed -i -e "/MSH/s/$MSH21U/Q1008YY/g" 1decode.txt
                                fi
                        ;;

                        *)
                                if [ "$MSH21" == "1" ] && [ "$MSHSEG" == "1" ]
                                then
                                        MSH21U=$(cat 1decode.txt | grep "^MSH" | cut -d '|' -f 22 | cut -d '^' -f 1)
                                        sed -i -e "/MSH/s/$MSH21U/Q2001YY$MSH21U/g" 1decode.txt
                                fi
                        ;;

                esac        
        }

        if [ "$MSH21" == "1" ] && [ "$MSHSEG" == "1" ]
        then
                msh
        fi

###MSH###

###PID2 AND PID3###
        for j in {"3","4"}
        do
                PIDSEG=$(cat 1decode.txt | grep "^PID" | wc -l)

                PID18=$(cat 1decode.txt | grep "^PID" | cut -d '|' -f $j | cut -d '^' -f 1 | wc -w)
                PID1818=$(cat 1decode.txt | grep "^PID" | cut -d '|' -f $j | grep -i "~" | wc -l)

                if [ "$PID18" == "1" ] && [ "$PIDSEG" == "1" ]
                then
                        PID18U=$(cat 1decode.txt | grep "^PID" | cut -d '|' -f $j | cut -d '^' -f 1)
                        sed -i -e "/PID/s/|$PID18U/|0000000000/g" 1decode.txt
                fi



                PIDINDX=$(cat 1decode.txt | grep "^PID" | cut -d '|' -f $j | grep "~" -o | wc -l)
                PIDINDX1=$((++PIDINDX)) 
                if [ "$PIDINDX" != "0" ] && [ "$PIDSEG" == "1" ]
                then
                        for ((d=2; d<=$PIDINDX1; d++))
                        do
                                pid182=$(cat 1decode.txt | grep "^PID" | cut -d '|' -f $j | grep -i '~' | cut -d '~' -f $d | cut -d '^' -f 1 | wc -w)
                                if [ "$pid182" == "1" ] && [ "$PIDSEG" == "1" ]
                                then
                                        pid1821=$(cat 1decode.txt | grep "^PID" | cut -d '|' -f $j | grep -i '~' | cut -d '~' -f $d | cut -d '^' -f 1)
                                        sed -i -e "/PID/s/$pid1821/1111111111/g" 1decode.txt
                                fi                                
                        done
                fi

        done
        
###PID2 AND PID3###

###PID5###
        pid5=$(cat 1decode.txt | grep "^PID" | cut -d '|' -f 6 | wc -w)
        PID5SEG=$(cat 1decode.txt | grep "^PID" | wc -l)
        if [ "$pid5" != "0" ] && [ "$PID5SEG" == "1" ]
        then
                pid51u=$(cat 1decode.txt | grep "^PID" | cut -d '|' -f 6 | cut -d '^' -f 1)
                sed -i -e "/PID/s/$pid51u/ffff/" 1decode.txt
                pid52u=$(cat 1decode.txt | grep "^PID" | cut -d '|' -f 6 | cut -d '^' -f 2)
                sed -i -e "/PID/s/$pid52u/llll/" 1decode.txt
        fi

###PID7###
        pid7=$(cat 1decode.txt | grep "^PID" | cut -d '|' -f 8 | wc -w)
        PID7SEG=$(cat 1decode.txt | grep "^PID" | wc -l)
        if [ "$pid7" == "1" ] && [ "$PID7SEG" == "1" ]
        then
                pid7u=$(cat 1decode.txt | grep "^PID" | cut -d '|' -f 8 | cut -d '^' -f 1)
                sed -i -e "/PID/s/$pid7u/19000101/" 1decode.txt
        fi

###PID18###
        pid18=$(cat 1decode.txt | grep "^PID" | cut -d '|' -f 19 | wc -w)
        PID18SEG=$(cat 1decode.txt | grep "^PID" | wc -l)
        if [ "$pid18" == "1" ] && [ "$PID18SEG" == "1" ]
        then
                pid18u=$(cat 1decode.txt | grep "^PID" | cut -d '|' -f 19 | cut -d '^' -f 1)
                sed -i -e "/PID/s/$pid18u/1111111111/" 1decode.txt
        fi
###PID18###

###PV1-17###
        for p in {"8","9","10","18"}
        do

                PVSEG=$(cat 1decode.txt | grep "^PV1" | wc -l)
                PV17=$(cat 1decode.txt | grep "^PV1" | cut -d '|' -f $p | cut -d '^' -f 1 | wc -w)
                PV71=$(cat 1decode.txt | grep "^PV1" | cut -d '|' -f $p | cut -d '^' -f 2 | wc -w)
                PV72=$(cat 1decode.txt | grep "^PV1" | cut -d '|' -f $p | cut -d '^' -f 3 | wc -w)

                if [ "$PV17" == "1" ] && [ "$PVSEG" == "1" ]
                then
                        PV17U=$(cat 1decode.txt | grep "^PV1" | cut -d '|' -f $p | cut -d '^' -f 1)
                        sed -i -e "/PV1/s/$PV17U/00000000000/" 1decode.txt
                fi

                if [ "$PV71" != "0" ] && [ "$PVSEG" == "1" ]
                then
                        PV71U=$(cat 1decode.txt | grep "^PV1" | cut -d '|' -f $p | cut -d '^' -f 2)
                        sed -i -e "/PV1/s/$PV71U/ffff/g" 1decode.txt
                fi

                if [ "$PV72" != "0" ] && [ "$PVSEG" == "1" ]
                then
                        PV72U=$(cat 1decode.txt | grep -i "^PV1" | cut -d '|' -f $p | cut -d '^' -f 3)
                        sed -i -e "/PV1/s/$PV72U/llll/g" 1decode.txt
                fi


                PVINDX=$(cat 1decode.txt | grep "^PV1" | cut -d '|' -f $p | grep "~" -o | wc -l)
                PVINDX1=$((++PVINDX)) 
                if [ "$PVINDX" != "0" ] && [ "$PVSEG" == "1" ]
                then
                        for ((s=2; s<=$PVINDX1; s++))
                        do
                                pv12=$(cat 1decode.txt | grep "^PV1" | cut -d '|' -f $p | grep -i '~' | cut -d '~' -f $s | cut -d '^' -f 1 | wc -w)
                                pv122=$(cat 1decode.txt | grep "^PV1" | cut -d '|' -f $p | grep -i '~' | cut -d '~' -f $s | cut -d '^' -f 2 | wc -w)
                                pv123=$(cat 1decode.txt | grep "^PV1" | cut -d '|' -f $p | grep -i '~' | cut -d '~' -f $s | cut -d '^' -f 3 | wc -w)

                                
                                if [ "$pv12" == "1" ] && [ "$PVSEG" == "1" ]
                                then
                                        pv121=$(cat 1decode.txt | grep "^PV1" | cut -d '|' -f $p | grep -i '~' | cut -d '~' -f $s | cut -d '^' -f 1)
                                        sed -i -e "/PV1/s/$pv121/1111111111/" 1decode.txt
                                fi

                                if [ "$pv122" != "0" ] && [ "$PVSEG" == "1" ]
                                then
                                        pv121=$(cat 1decode.txt | grep "^PV1" | cut -d '|' -f $p | grep -i '~' | cut -d '~' -f $s | cut -d '^' -f 2)
                                        sed -i -e "/PV1/s/$pv121/ffff/g" 1decode.txt
                                fi

                                if [ "$pv123" != "0" ] && [ "$PVSEG" == "1" ]
                                then
                                        pv121=$(cat 1decode.txt | grep "^PV1" | cut -d '|' -f $p | grep -i '~' | cut -d '~' -f $s | cut -d '^' -f 3)
                                        sed -i -e "/PV1/s/$pv121/llll/g" 1decode.txt
                                fi
                        done
                fi
        done


###AIP###
        for i in {"AIP||","AIP|1|","AIP|2|","AIP|3|","AIP|4|","AIP|5|"}
        do
                AIPSEG=$(cat 1decode.txt | grep "^$i" | wc -l)

                AIP1=$(cat 1decode.txt | grep "^$i" | cut -d '|' -f 4 | cut -d '^' -f 1 | wc -w)
                AIP10=$(cat 1decode.txt | grep "^$i" | cut -d '|' -f 4 | cut -d '^' -f 2 | wc -w)
                AIP100=$(cat 1decode.txt | grep "^$i" | cut -d '|' -f 4 | cut -d '^' -f 3 | wc -w)
                AIP11=$(cat 1decode.txt | grep "^$i" | cut -d '|' -f 4 | grep -i "~" | wc -w)

                if [ "$AIP1" != "0" ] && [ "$AIPSEG" != "0" ] 
                then
                        AIP1U=$(cat 1decode.txt | grep "^$i" | cut -d '|' -f 4 | cut -d '^' -f 1)
                        for oo in $AIP1U
                        do
                                sed -i -e "/$i/s/$oo/0000000000/g" 1decode.txt
                        done
                fi

                if [ "$AIP10" != "0" ] && [ "$AIPSEG" != "0" ] 
                then
                        AIP2U=$(cat 1decode.txt | grep "^$i" | cut -d '|' -f 4 | cut -d '^' -f 2)
                        for ooo in $AIP2U
                        do
                                sed -i -e "/$i/s/$ooo/ffff/g" 1decode.txt
                        done
                fi

                if [ "$AIP100" != "0" ] && [ "$AIPSEG" != "0" ]
                then
                        AIP3U=$(cat 1decode.txt | grep "^$i" | cut -d '|' -f 4 | cut -d '^' -f 3)
                        for oooo in $AIP3U
                        do
                                sed -i -e "/$i/s/$oooo/llll/g" 1decode.txt
                        done
                fi


                AIPINDX=$(cat 1decode.txt | grep "^$i" | cut -d "|" -f 4 | grep "~" -o | wc -l)
                AIPINDX1=$((++AIPINDX))

                if [ "AIPINDX" != "0" ] && [ "AIPSEG" != "0" ]
                then
                        for ((v=2; v<=$AIPINDX1; v++))
                        do
                                aip12=$(cat 1decode.txt | grep "^$i" | cut -d '|' -f 4 | grep -i '~' | cut -d '~' -f $v | cut -d '^' -f 1 | wc -w)
                                aip121=$(cat 1decode.txt | grep "^$i" | cut -d '|' -f 4 | grep -i '~' | cut -d '~' -f $v | cut -d '^' -f 2 | wc -w)
                                aip122=$(cat 1decode.txt | grep "^$i" | cut -d '|' -f 4 | grep -i '~' | cut -d '~' -f $v | cut -d '^' -f 3 | wc -w)

                                if [ "$aip12" != "0" ] && [ "$AIPSEG" != "0" ] 
                                then
                                        aip21=$(cat 1decode.txt | grep "^$i" | cut -d '|' -f 4 | grep -i '~' | cut -d '~' -f $v | cut -d '^' -f 1)
                                        sed -i -e "/$i/s/$aip21/1111111111/g" 1decode.txt
                                fi

                                if [ "$aip121" != "0" ] && [ "$AIPSEG" != "0" ] 
                                then
                                        aip211=$(cat 1decode.txt | grep "^$i" | cut -d '|' -f 4 | grep -i '~' | cut -d '~' -f $v | cut -d '^' -f 2)
                                        sed -i -e "/$i/s/$aip211/ffff/g" 1decode.txt
                                fi

                                if [ "$aip122" != "0" ] && [ "$AIPSEG" != "0" ] 
                                then
                                        aip212=$(cat 1decode.txt | grep "^$i" | cut -d '|' -f 4 | grep -i '~' | cut -d '~' -f $v | cut -d '^' -f 3)
                                        sed -i -e "/$i/s/$aip212/llll/g" 1decode.txt
                                fi
                        

                                if [ "$AIP1" != "0" ] && [ "$AIPSEG" != "0" ] && [ "$AIPSEG" != "1" ] && [ "$aip12" == "1" ]
                                then
                                        aip231=$(cat 1decode.txt | grep "^$i" | cut -d '|' -f 4 | grep -i '~' | cut -d '~' -f $v | cut -d '^' -f 1)
                                        for e in $aip231
                                        do
                                                sed -i -e "/$i/s/$e/0000000000/g" 1decode.txt
                                        done
                                fi

                                if [ "$AIP1" != "0" ] && [ "$AIPSEG" != "0" ] && [ "$AIPSEG" != "1" ] && [ "$aip121" == "1" ]
                                then
                                        aip232=$(cat 1decode.txt | grep "^$i" | cut -d '|' -f 4 | grep -i '~' | cut -d '~' -f $v | cut -d '^' -f 2)
                                        for ee in $aip232
                                        do
                                                sed -i -e "/$i/s/$ee/ffff/g" 1decode.txt
                                        done
                                fi  

                                if [ "$AIP1" != "0" ] && [ "$AIPSEG" != "0" ] && [ "$AIPSEG" != "1" ] && [ "$aip122" == "1" ]
                                then
                                        aip233=$(cat 1decode.txt | grep "^$i" | cut -d '|' -f 4 | grep -i '~' | cut -d '~' -f $v | cut -d '^' -f 3)
                                        for eee in $aip233
                                        do
                                                sed -i -e "/$i/s/$eee/llll/g" 1decode.txt
                                        done
                                fi
                        done        
                fi
        done



        sed -i -z "s/\n/\r/g" 1decode.txt
        echo ""
        echo "Encoding the modified data part..."
        openssl base64 -A -in ./1decode.txt -out ./1encode.txt

        a=$(cat 1encode.txt)

        b=$(cat hl7v2-sample.json | grep -i data | cut -d ':' -f 2 | cut -c 3- | rev | cut -c 2- | rev)
        sed "s|$b|$a|" hl7v2-sample.json > 1final-message.json

        echo ""
        echo "Creating New message..."
#        curl -X POST -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" -H "Content-Type: application/json; charset=utf-8" --data-binary @1final-message.json "https://healthcare.googleapis.com/v1beta1/projects/poc-hl7-clientgp1/locations/us-central1/datasets/pocset-poc-hl7-clientgp1/hl7V2Stores/HL7v2-datastore/messages" > 1output.txt
        curl -X POST -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" -H "Content-Type: application/json; charset=utf-8" --data-binary @1final-message.json "https://healthcare.googleapis.com/v1beta1/projects/clientgp1-hl7-prod/locations/us-central1/datasets/clientgp1-hl7-prod-dataset-01/hl7V2Stores/clientgp1-hl7-prod-datastore-01-deidentify/messages" > 1output.txt

        d=$(jq '.name' 1output.txt | cut -d '/' -f 10 | rev | cut -c 2- | rev )
        e=$(date)
        ss=$(echo OLD MESSAGE ID -- $qqq)
        ff=$(echo NEW MESSAGE ID -- $d)
        echo ""
        echo "New Message id = $d"

        if [ "$d" == "nul" ]
        then
                cat 1decode.txt > null-messages/$qqq.txt
        fi 

        echo $ss "|" $ff "|" $e >> new-message-id-2.txt

done

rm 1decode.txt 1encode.txt hl7v2-sample.json 1final-message.json 1output.txt 1datapart.txt

