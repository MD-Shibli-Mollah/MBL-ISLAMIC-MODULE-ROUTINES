* @ValidationCode : MjotMTE1MzI5NDMzMDpDcDEyNTI6MTU5MjgwMTg4NDQ0MTpERUxMOi0xOi0xOjA6MDpmYWxzZTpOL0E6REVWXzIwMTcxMC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 22 Jun 2020 10:58:04
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.I.TXN.PROFILE
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Developed By- Akhter Hossain
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.MBL.TXN.PROFILE
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING EB.ErrorProcessing
    $USING ST.Customer
    $USING AC.AccountOpening
    
    GOSUB INIT
    GOSUB OPEN.FILES
    GOSUB PROCESS

RETURN
    
INIT:

    FN.TXN.PROF = 'F.MBL.TXN.PROFILE'
    F.TXN.PROF = ''

    FN.CUS = 'F.CUSTOMER'
    F.CUS = ''

    FN.AC = 'F.ACCOUNT'
    F.AC = ''
RETURN

OPEN.FILES:
    EB.DataAccess.Opf(FN.TXN.PROF, F.TXN.PROF)
    EB.DataAccess.Opf(FN.CUS,F.CUS)
    EB.DataAccess.Opf(FN.AC,F.AC)

RETURN

PROCESS:
    Y.CASH.DEP.NO = EB.SystemTables.getRNew(MB.TP.CASH.DEP.NO)
    Y.TRF.DEP.NO = EB.SystemTables.getRNew(MB.TP.TRF.DEP.NO)
    Y.RMT.DEP.NO = EB.SystemTables.getRNew(MB.TP.RMT.DEP.NO)
    Y.EXP.DEP.NO = EB.SystemTables.getRNew(MB.TP.EXP.DEP.NO)
    Y.BOA.DEP.NO = EB.SystemTables.getRNew(MB.TP.BOA.DEP.NO)
    Y.OTH.DEP.NO = EB.SystemTables.getRNew(MB.TP.OTH.DEP.NO)
    Y.TOT.DEP.NO = Y.CASH.DEP.NO + Y.TRF.DEP.NO + Y.RMT.DEP.NO + Y.EXP.DEP.NO + Y.BOA.DEP.NO + Y.OTH.DEP.NO
    EB.SystemTables.setRNew(MB.TP.TOT.DEP.NO, Y.TOT.DEP.NO)

    Y.CASH.DEP.AMT = EB.SystemTables.getRNew(MB.TP.CASH.DEP.AMT)
    Y.TRF.DEP.AMT = EB.SystemTables.getRNew(MB.TP.TRF.DEP.AMT)
    Y.RMT.DEP.AMT = EB.SystemTables.getRNew(MB.TP.RMT.DEP.AMT)
    Y.EXP.DEP.AMT = EB.SystemTables.getRNew(MB.TP.EXP.DEP.AMT)
    Y.BOA.DEP.AMT = EB.SystemTables.getRNew(MB.TP.BOA.DEP.AMT)
    Y.OTH.DEP.AMT = EB.SystemTables.getRNew(MB.TP.OTH.DEP.AMT)
    Y.TOT.DEP.AMT = Y.CASH.DEP.AMT + Y.TRF.DEP.AMT  + Y.RMT.DEP.AMT + Y.EXP.DEP.AMT + Y.BOA.DEP.AMT + Y.OTH.DEP.AMT
    EB.SystemTables.setRNew(MB.TP.TOT.DEP.AMT, Y.TOT.DEP.AMT)

    Y.CASH.WDL.NO =  EB.SystemTables.getRNew(MB.TP.CASH.WDL.NO)
    Y.TRF.WDL.NO =  EB.SystemTables.getRNew(MB.TP.TRF.WDL.NO)
    Y.RMT.WDL.NO =  EB.SystemTables.getRNew(MB.TP.RMT.WDL.NO)
    Y.IMP.WDL.NO =  EB.SystemTables.getRNew(MB.TP.IMP.WDL.NO)
    Y.BOA.WDL.NO =  EB.SystemTables.getRNew(MB.TP.BOA.WDL.NO)
    Y.OTH.WDL.NO =  EB.SystemTables.getRNew(MB.TP.OTH.WDL.NO)
    Y.TOT.WDL.NO = Y.CASH.WDL.NO + Y.TRF.WDL.NO + Y.RMT.WDL.NO + Y.IMP.WDL.NO + Y.BOA.WDL.NO + Y.OTH.WDL.NO
    EB.SystemTables.setRNew(MB.TP.TOT.WDL.NO, Y.TOT.WDL.NO)

    Y.CASH.WDL.AMT = EB.SystemTables.getRNew(MB.TP.CASH.WDL.AMT)
    Y.TRF.WDL.AMT =  EB.SystemTables.getRNew(MB.TP.TRF.WDL.AMT)
    Y.RMT.WDL.AMT =  EB.SystemTables.getRNew(MB.TP.RMT.WDL.AMT)
    Y.IMP.WDL.AMT =  EB.SystemTables.getRNew(MB.TP.IMP.WDL.AMT)
    Y.BOA.WDL.AMT =  EB.SystemTables.getRNew(MB.TP.BOA.WDL.AMT)
    Y.OTH.WDL.AMT =  EB.SystemTables.getRNew(MB.TP.OTH.WDL.AMT)
    Y.TOT.WDL.AMT = Y.CASH.WDL.AMT + Y.TRF.WDL.AMT + Y.RMT.WDL.AMT + Y.IMP.WDL.AMT + Y.BOA.WDL.AMT + Y.OTH.WDL.AMT
    EB.SystemTables.setRNew(MB.TP.TOT.WDL.AMT, Y.TOT.WDL.AMT)


************
    !Risk Grading:
************
    Y.CORP.INDV.MARKER = EB.SystemTables.getRNew(MB.TP.CORP.INDV.MARKER)

    Y.AC.NO = EB.SystemTables.getIdNew()
** Account NO Format as L-PPP-SSSSSSSS-C where PPP is the Prefix
    Y.PREFIX = Y.AC.NO[2,2]

    Y.TOT.TXN.VOL = Y.TOT.DEP.AMT + Y.TOT.WDL.AMT
    Y.TOT.TXN.NO =  Y.TOT.DEP.NO + Y.TOT.WDL.NO
    Y.TOT.CSH.TXN.VOL = Y.CASH.DEP.AMT + Y.CASH.WDL.AMT
    Y.TOT.CSH.TXN.NO = Y.CASH.DEP.NO + Y.CASH.WDL.NO

    IF Y.CORP.INDV.MARKER EQ "CORPORATE" THEN
        IF Y.PREFIX EQ 12 THEN

            IF Y.TOT.TXN.VOL LE '500000' THEN
                EB.SystemTables.setRNew(MB.TP.TOT.TXN.AMT, 'CORP: SB 0 - 5 Lac = Low (0)')
            END

            IF Y.TOT.TXN.VOL GT '500000' AND Y.TOT.TXN.VOL LE '2000000' THEN
                EB.SystemTables.setRNew(MB.TP.TOT.TXN.AMT,'CORP: SB 5 - 20 Lac = Medium (1)')
            END

            IF Y.TOT.TXN.VOL GT '2000000' THEN
                EB.SystemTables.setRNew(MB.TP.TOT.TXN.AMT, 'CORP: SB Above 20 Lac = High (3)')
            END


            IF Y.TOT.TXN.NO LE '20' THEN
                EB.SystemTables.setRNew(MB.TP.TOT.TXN.NO, 'CORP: SB 0 - 20 = Low (0)')
            END

            IF Y.TOT.TXN.NO GE '21' AND Y.TOT.TXN.NO LE '50' THEN
                EB.SystemTables.setRNew(MB.TP.TOT.TXN.NO, 'CORP: SB 21 - 50 = Medium (1)')
            END

            IF Y.TOT.TXN.NO GT '50' THEN
                EB.SystemTables.setRNew(MB.TP.TOT.TXN.NO, 'CORP: SB Above 50 = High (3)')
            END


            IF Y.TOT.CSH.TXN.VOL LE '200000' THEN
                EB.SystemTables.setRNew(MB.TP.CASH.TXN.AMT, 'CORP: SB 0 - 2 Lac = Low (0)')
            END

            IF Y.TOT.CSH.TXN.VOL GT '200000' AND Y.TOT.CSH.TXN.VOL LE '700000' THEN
                EB.SystemTables.setRNew(MB.TP.CASH.TXN.AMT, 'CORP: SB 2 - 7 Lac = Medium (1)')
            END

            IF Y.TOT.CSH.TXN.VOL GT '700000' THEN
                EB.SystemTables.setRNew(MB.TP.CASH.TXN.AMT, 'CORP: SB Above 7 Lac = High (3)')
            END


            IF Y.TOT.CSH.TXN.NO LE '5' THEN
                EB.SystemTables.setRNew(MB.TP.CASH.TXN.NO, 'CORP: SB 0 - 5 = Low (0)')
            END

            IF Y.TOT.CSH.TXN.NO GE '6' AND Y.TOT.CSH.TXN.NO LE '10' THEN
                EB.SystemTables.setRNew(MB.TP.CASH.TXN.NO, 'CORP: SB 6 - 10 = Medium (1)')
            END

            IF Y.TOT.CSH.TXN.NO GT '10' THEN
                EB.SystemTables.setRNew(MB.TP.CASH.TXN.NO, 'CORP: SB Above 10 = High (3)')
            END


        END ELSE

            IF Y.TOT.TXN.VOL LE '1000000' THEN
                EB.SystemTables.setRNew(MB.TP.TOT.TXN.AMT, 'CORP: CD 0 - 10 Lac = Low (0)')
            END

            IF Y.TOT.TXN.VOL GT '1000000' AND Y.TOT.TXN.VOL LE '5000000' THEN
                EB.SystemTables.setRNew(MB.TP.TOT.TXN.AMT, 'CORP: CD 10 - 50 Lac = Medium (1)')
            END

            IF Y.TOT.TXN.VOL GT '5000000' THEN
                EB.SystemTables.setRNew(MB.TP.TOT.TXN.AMT, 'CORP: CD Above 50 Lac = High (3)')
            END

            IF Y.TOT.TXN.NO LE '100' THEN
                EB.SystemTables.setRNew(MB.TP.TOT.TXN.NO, 'CORP: CD 0 - 100 = Low (0)')
            END

            IF Y.TOT.TXN.NO GE '101' AND Y.TOT.TXN.NO LE '250' THEN
                EB.SystemTables.setRNew(MB.TP.TOT.TXN.NO, 'CORP: CD 101 - 250 = Medium (1)')
            END

            IF Y.TOT.TXN.NO GT '250' THEN
                EB.SystemTables.setRNew(MB.TP.TOT.TXN.NO, 'CORP: CD Above 250 = Medium (3)')
            END

            IF Y.TOT.CSH.TXN.VOL LE '1000000' THEN
                EB.SystemTables.setRNew(MB.TP.CASH.TXN.AMT, 'CORP: CD 0 - 10 Lac = Low (0)')
            END

            IF Y.TOT.CSH.TXN.VOL GT '1000000' AND Y.TOT.CSH.TXN.VOL LE '2500000' THEN
                EB.SystemTables.setRNew(MB.TP.CASH.TXN.AMT, 'CORP: CD 10 - 25 Lac = Medium (1)')
            END


            IF Y.TOT.CSH.TXN.VOL GT '2500000' THEN
                EB.SystemTables.setRNew(MB.TP.CASH.TXN.AMT, 'CORP: CD Above 25 Lac = High (3)')
            END

            IF Y.TOT.CSH.TXN.NO LE '15' THEN
                EB.SystemTables.setRNew(MB.TP.CASH.TXN.NO, 'CORP: CD 0 - 15 = Low (0)')
            END

            IF Y.TOT.CSH.TXN.NO GE '16' AND Y.TOT.CSH.TXN.NO LE '30' THEN
                EB.SystemTables.setRNew(MB.TP.CASH.TXN.NO, 'CORP: CD 16 - 30 = Medium (1)')
            END

            IF Y.TOT.CSH.TXN.NO GT '30' THEN
                EB.SystemTables.setRNew(MB.TP.CASH.TXN.NO, 'CORP: CD Above 30 = High (3)')
            END
        END
    END


    IF Y.CORP.INDV.MARKER EQ "INDIVIDUAL" THEN
        IF Y.PREFIX EQ 12 THEN

            IF Y.TOT.TXN.VOL LE '500000' THEN
                EB.SystemTables.setRNew(MB.TP.TOT.TXN.AMT, 'INDV: SB 0 - 5 Lac = Low (0)')
            END

            IF Y.TOT.TXN.VOL GT '500000' AND Y.TOT.TXN.VOL LE '1000000' THEN
                EB.SystemTables.setRNew(MB.TP.TOT.TXN.AMT, 'INDV: SB 5 - 10 Lac = Medium (1)')
            END

            IF Y.TOT.TXN.VOL GT '1000000' THEN
                EB.SystemTables.setRNew(MB.TP.TOT.TXN.AMT, 'INDV: SB Above 10 Lac = High (3)')
            END


            IF Y.TOT.TXN.NO LE '10' THEN
                EB.SystemTables.setRNew(MB.TP.TOT.TXN.NO, 'INDV: SB 0 - 10 = Low (0)')
            END

            IF Y.TOT.TXN.NO GE '11' AND Y.TOT.TXN.NO LE '20' THEN
                EB.SystemTables.setRNew(MB.TP.TOT.TXN.NO, 'INDV: SB 11 - 20 = Medium (1)')
            END

            IF Y.TOT.TXN.NO GT '20' THEN
                EB.SystemTables.setRNew(MB.TP.TOT.TXN.NO, 'INDV: SB Above 20 = High (3)')
            END


            IF Y.TOT.CSH.TXN.VOL LE '200000' THEN
                EB.SystemTables.setRNew(MB.TP.CASH.TXN.AMT, 'INDV: SB 0 - 2 Lac = Low (0)')
            END

            IF Y.TOT.CSH.TXN.VOL GT '200000' AND Y.TOT.CSH.TXN.VOL LE '500000' THEN
                EB.SystemTables.setRNew(MB.TP.CASH.TXN.AMT, 'INDV: SB 2 - 5 Lac = Medium (1)')
            END

            IF Y.TOT.CSH.TXN.VOL GT '500000' THEN
                EB.SystemTables.setRNew(MB.TP.CASH.TXN.AMT, 'INDV: SB Above 5 Lac = High (3)')
            END


            IF Y.TOT.CSH.TXN.NO LE '5' THEN
                EB.SystemTables.setRNew(MB.TP.CASH.TXN.NO, 'INDV: SB 0 - 5 = Low (0)')
            END

            IF Y.TOT.CSH.TXN.NO GE '6' AND Y.TOT.CSH.TXN.NO LE '10' THEN
                EB.SystemTables.setRNew(MB.TP.CASH.TXN.NO, 'INDV: SB 6 - 10 = Medium (1)')
            END

            IF Y.TOT.CSH.TXN.NO GT '10' THEN
                EB.SystemTables.setRNew(MB.TP.CASH.TXN.NO, 'INDV: SB Above 10 = High (3)')
            END


        END ELSE

            IF Y.TOT.TXN.VOL LE '1000000' THEN
                EB.SystemTables.setRNew(MB.TP.TOT.TXN.AMT, 'INDV: CD 0 - 10 Lac = Low (0)')
            END

            IF Y.TOT.TXN.VOL GT '1000000' AND Y.TOT.TXN.VOL LE '2000000' THEN
                EB.SystemTables.setRNew(MB.TP.TOT.TXN.AMT, 'INDV: CD 10 - 20 Lac = Medium (1)')
            END

            IF Y.TOT.TXN.VOL GT '2000000' THEN
                EB.SystemTables.setRNew(MB.TP.TOT.TXN.AMT, 'INDV: CD Above 20 Lac = High (3)')
            END

            IF Y.TOT.TXN.NO LE '15' THEN
                EB.SystemTables.setRNew(MB.TP.TOT.TXN.NO, 'INDV: CD 0 - 15 = Low (0)')
            END

            IF Y.TOT.TXN.NO GE '16' AND Y.TOT.TXN.NO LE '25' THEN
                EB.SystemTables.setRNew(MB.TP.TOT.TXN.NO, 'INDV: CD 16 - 25 = Medium (1)')
            END

            IF Y.TOT.TXN.NO GT '25' THEN
                EB.SystemTables.setRNew(MB.TP.TOT.TXN.NO, 'INDV: CD Above 25 = Medium (3)')
            END

            IF Y.TOT.CSH.TXN.VOL LE '500000' THEN
                EB.SystemTables.setRNew(MB.TP.CASH.TXN.AMT, 'INDV: CD 0 - 5 Lac = Low (0)')
            END

            IF Y.TOT.CSH.TXN.VOL GT '500000' AND Y.TOT.CSH.TXN.VOL LE '1000000' THEN
                EB.SystemTables.setRNew(MB.TP.CASH.TXN.AMT, 'INDV: CD 5 - 10 Lac = Medium (1)')
            END


            IF Y.TOT.CSH.TXN.VOL GT '1000000' THEN
                EB.SystemTables.setRNew(MB.TP.CASH.TXN.AMT, 'INDV: CD Above 10 Lac = High (3)')
            END

            IF Y.TOT.CSH.TXN.NO LE '10' THEN
                EB.SystemTables.setRNew(MB.TP.CASH.TXN.NO, 'INDV: CD 0 - 10 = Low (0)')
            END

            IF Y.TOT.CSH.TXN.NO GE '11' AND Y.TOT.CSH.TXN.NO LE '20' THEN
                EB.SystemTables.setRNew(MB.TP.CASH.TXN.NO, 'INDV: CD 11 - 20 = Medium (1)')
            END

            IF Y.TOT.CSH.TXN.NO GT '20' THEN
                EB.SystemTables.setRNew(MB.TP.CASH.TXN.NO, 'INDV: CD Above 20 = High (3)')
            END
        END
    END

***************************
    !Control for Data Selection:
***************************
    EB.DataAccess.FRead(FN.AC, Y.AC.NO, AC.REC, F.AC, AC.ERR)
    Y.AC.CUS = AC.REC<AC.AccountOpening.Account.Customer>
    EB.DataAccess.FRead(FN.CUS,Y.AC.CUS,CUS.REC,F.CUS,CUS.ERR)
    Y.CUS.SECTOR = CUS.REC<ST.Customer.Customer.EbCusSector>


    IF Y.CUS.SECTOR EQ '1001' OR Y.CUS.SECTOR EQ '1002' THEN
        IF Y.CORP.INDV.MARKER EQ 'CORPORATE' THEN
            EB.SystemTables.setAf(MB.TP.CORP.INDV.MARKER)
            EB.SystemTables.setEtext("Type of Account Can't be CORPORATE for Customer Sector 1001 or 1002 !!")
            EB.ErrorProcessing.StoreEndError()
        END
    END ELSE
        IF Y.CORP.INDV.MARKER EQ 'INDIVIDUAL' THEN
            EB.SystemTables.setAf(MB.TP.CORP.INDV.MARKER)
            EB.SystemTables.setEtext("Type of Account Can't be Individual for Customer Sector Other than 1001 or 1002 !!")
            EB.ErrorProcessing.StoreEndError()

        END
    END

    Y.NOB.OCCP = EB.SystemTables.getRNew(MB.TP.NOB.OCCUPATION)
    Y.NOB.OCCP.TYPE = Y.NOB.OCCP[1,4]

    Y.NW.MI = EB.SystemTables.getRNew(MB.TP.NET.WORTH.MONT.INC)
    Y.NW.MI.TYPE = Y.NW.MI[1,4]

    IF Y.CORP.INDV.MARKER EQ 'CORPORATE' THEN

        IF Y.NOB.OCCP.TYPE EQ 'INDV' THEN
            EB.SystemTables.setAf(MB.TP.NOB.OCCUPATION)
            EB.SystemTables.setEtext("Nature of Business/Occupation Can't be INDIVIDUAL as Type of Account is CORPORATE !!")
            EB.ErrorProcessing.StoreEndError()
        END
        IF Y.NW.MI.TYPE EQ 'INDV' THEN
            EB.SystemTables.setAf(MB.TP.NET.WORTH.MONT.INC)
            EB.SystemTables.setEtext("Net Worth-Org/Monthly Income Can't be INDIVIDUAL as Type of Account is CORPORATE !!")
            EB.ErrorProcessing.StoreEndError()
        END
    END

    IF Y.CORP.INDV.MARKER EQ 'INDIVIDUAL' THEN

        IF Y.NOB.OCCP.TYPE EQ 'CORP' THEN
            EB.SystemTables.setAf(MB.TP.NOB.OCCUPATION)
            EB.SystemTables.setEtext("Nature of Business/Occupation Can't be CORPORATE as Type of Account is INDIVIDUAL !!")
            EB.ErrorProcessing.StoreEndError()
        END
        IF Y.NW.MI.TYPE EQ 'CORP' THEN
            EB.SystemTables.setAf(MB.TP.NET.WORTH.MONT.INC)
            EB.SystemTables.setEtext("Net Worth-Org/Monthly Income Can't be CORPORATE as Type of Account is INDIVIDUAL !!")
            EB.ErrorProcessing.StoreEndError()
        END
    END

**********************************************************************
    !Making Mandatory (NOB.OCCUPATION, NET.WORTH.MONT.INC, ACC.OPENED.WAY):
**********************************************************************

    IF EB.SystemTables.getRNew(MB.TP.NOB.OCCUPATION) EQ "" THEN
        EB.SystemTables.setAf(MB.TP.NOB.OCCUPATION)
        EB.SystemTables.setEtext("Nature of Business/Occupation Field is Blank !!!")
        EB.ErrorProcessing.StoreEndError()

    END

    IF EB.SystemTables.getRNew(MB.TP.NET.WORTH.MONT.INC) EQ "" THEN
        EB.SystemTables.setAf(MB.TP.NET.WORTH.MONT.INC)
        EB.SystemTables.setEtext("Net Worth-Org/Monthly Income Field is Blank !!!")
        EB.ErrorProcessing.StoreEndError()
    END

    IF EB.SystemTables.getRNew(MB.TP.ACC.OPENED.WAY) EQ "" THEN
        EB.SystemTables.setAf(MB.TP.ACC.OPENED.WAY)
        EB.SystemTables.setEtext("Account Opened Through Field is Blank !!!")
        EB.ErrorProcessing.StoreEndError()

    END

********************
    !Risk Grading Score:
********************

    Y.NOB.OCP.POINT = EB.SystemTables.getRNew(MB.TP.NOB.OCCUPATION)
    Y.NOB.OCP.POINT = FIELD(Y.NOB.OCP.POINT,"(",2)
    Y.NOB.OCP.POINT = FIELD(Y.NOB.OCP.POINT,")",1)

    Y.NW.MI.POINT = EB.SystemTables.getRNew(MB.TP.NET.WORTH.MONT.INC)
    Y.NW.MI.POINT = FIELD(Y.NW.MI.POINT,"(",2)
    Y.NW.MI.POINT = FIELD(Y.NW.MI.POINT,")",1)

    Y.AC.OPN.POINT = EB.SystemTables.getRNew(MB.TP.ACC.OPENED.WAY)
    Y.AC.OPN.POINT = FIELD(Y.AC.OPN.POINT,"(",2)
    Y.AC.OPN.POINT = FIELD(Y.AC.OPN.POINT,")",1)

    Y.TOT.TXN.AMT.POINT = EB.SystemTables.getRNew(MB.TP.TOT.TXN.AMT)
    Y.TOT.TXN.AMT.POINT = FIELD(Y.TOT.TXN.AMT.POINT,"(",2)
    Y.TOT.TXN.AMT.POINT = FIELD(Y.TOT.TXN.AMT.POINT,")",1)

    Y.TOT.TXN.NO.POINT = EB.SystemTables.getRNew(MB.TP.TOT.TXN.NO)
    Y.TOT.TXN.NO.POINT = FIELD(Y.TOT.TXN.NO.POINT,"(",2)
    Y.TOT.TXN.NO.POINT = FIELD(Y.TOT.TXN.NO.POINT,")",1)


    Y.TOT.CSH.TXN.AMT.POINT = EB.SystemTables.getRNew(MB.TP.CASH.TXN.AMT)
    Y.TOT.CSH.TXN.AMT.POINT = FIELD(Y.TOT.CSH.TXN.AMT.POINT,"(",2)
    Y.TOT.CSH.TXN.AMT.POINT = FIELD(Y.TOT.CSH.TXN.AMT.POINT,")",1)

    Y.TOT.CSH.TXN.NO.POINT = EB.SystemTables.getRNew(MB.TP.CASH.TXN.NO)
    Y.TOT.CSH.TXN.NO.POINT = FIELD(Y.TOT.CSH.TXN.NO.POINT,"(",2)
    Y.TOT.CSH.TXN.NO.POINT = FIELD(Y.TOT.CSH.TXN.NO.POINT,")",1)

    Y.TOTAL.RISK.SUM=''
    Y.TOTAL.RISK.SUM = Y.NOB.OCP.POINT + Y.NW.MI.POINT + Y.AC.OPN.POINT + Y.TOT.TXN.AMT.POINT + Y.TOT.TXN.NO.POINT + Y.TOT.CSH.TXN.AMT.POINT + Y.TOT.CSH.TXN.NO.POINT

    Y.TOTAL.RISK.RATING.PRINT = ''

    IF Y.TOTAL.RISK.SUM GE 14 THEN
        Y.TOTAL.RISK.RATING.PRINT = "High"
    END ELSE
        Y.TOTAL.RISK.RATING.PRINT = "Low"
    END

    EB.SystemTables.setRNew(MB.TP.TOTAL.RISK.SUM, Y.TOTAL.RISK.SUM)
    EB.SystemTables.setRNew(MB.TP.TOTAL.RISK.RATING, Y.TOTAL.RISK.RATING.PRINT)

RETURN


END
