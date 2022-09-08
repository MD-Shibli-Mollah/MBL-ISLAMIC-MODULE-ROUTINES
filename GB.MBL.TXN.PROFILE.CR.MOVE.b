* @ValidationCode : MjoxODY4MTA1Nzg0OkNwMTI1MjoxNTk0MjMxMTQyNTY5OkRFTEw6LTE6LTE6MDowOmZhbHNlOk4vQTpERVZfMjAxNzEwLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 08 Jul 2020 23:59:02
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : DELL
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.0
SUBROUTINE GB.MBL.TXN.PROFILE.CR.MOVE
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Developed by : s.azam@fortress-global.com
* Modification History :
* Transaction Profile Credit Override and Transaction Validation
*-----------------------------------------------------------------------------
   
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_AA.APP.COMMON
    $INSERT I_EB.EXTERNAL.COMMON
    $INSERT I_F.FT.TXN.TYPE.CONDITION
    $INSERT I_F.MBL.TXN.PROFILE
    $INSERT I_F.MBL.TXN.PROFILE.ENTRY
    $INSERT I_F.MBL.TXN.PROFILE.PARAM
    
    $USING EB.SystemTables
    $USING AA.Framework
    $USING FT.Contract
    $USING FT.Config
    $USING TT.Contract
    $USING TT.Config
    $USING EB.DataAccess
    $USING EB.ErrorProcessing
    $USING EB.OverrideProcessing
    $USING EB.TransactionControl
*-----------------------------------------------------------------------------
   
    Y.AC.NO = c_aalocLinkedAccount
    Y.TXN.AMT =  c_aalocArrActivityRec<AA.Framework.ArrangementActivity.ArrActTxnAmount>
    Y.TXN.REF = FIELD(c_aalocArrActivityRec<AA.Framework.ArrangementActivity.ArrActTxnContractId>,'\',1)
    Y.SYS.ID = c_aalocArrActivityRec<AA.Framework.ArrangementActivity.ArrActTxnSystemId>
    Y.RECORD.STATUS = c_aalocActivityStatus
    
    IF Y.AC.NO MATCHES '3A...' THEN
        RETURN
    END
    
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
*****
INIT:
*****

    FN.TP = 'F.MBL.TXN.PROFILE'
    F.TP = ''
    
    FN.TP.ENTRY = 'F.MBL.TXN.PROFILE.ENTRY'
    F.TP.ENTRY = ''
    FN.PARAM = 'F.MBL.TXN.PROFILE.PARAM'
    F.PARAM = ''
    FN.TT = 'F.TELLER'
    F.TT = ''
    FN.TT.NAU = 'F.TELLER$NAU'
    F.TT.NAU = ''
    FN.FT = 'F.FUNDS.TRANSFER'
    F.FT = ''
    FN.FT.NAU = 'F.FUNDS.TRANSFER$NAU'
    F.FT.NAU = ''
    FN.FT.TYPE = 'F.FT.TXN.TYPE.CONDITION'
    F.FT.TYPE = ''
    FN.OR = 'F.OVERRIDE'
    F.OR = ''
    Y.TOT.TXN.AMT = ''
    
*Y.TOT.DEP.TXN.CODE = '52':VM:'89':FM:'294':VM:'92':VM:'93':VM:'96':VM:'68'
*Y.DEPOSIT.PARTICULAR ='Cash Deposit (Inc of Online/ATM)':FM:'Transfer/ Deposit by Instruments':FM:'Foreign Inward Remittance':FM:'Receipt of Export Proceed':FM:'Deposit/Transfer From BO Account':FM:'Others'
RETURN
**********
OPENFILES:
**********

    EB.DataAccess.Opf(FN.TP,F.TP)
    EB.DataAccess.Opf(FN.TP.ENTRY,F.TP.ENTRY)
    EB.DataAccess.Opf(FN.PARAM,F.PARAM)
    EB.DataAccess.Opf(FN.FT,F.FT)
    EB.DataAccess.Opf(FN.TT,F.TT)
    EB.DataAccess.Opf(FN.FT.NAU,F.FT.NAU)
    EB.DataAccess.Opf(FN.TT.NAU,F.TT.NAU)
    EB.DataAccess.Opf(FN.FT.TYPE,F.FT.TYPE)
    EB.DataAccess.Opf(FN.OR,F.OR)
RETURN

********
PROCESS:
********
    Y.PARAM.ID = 'SYSTEM'
    EB.DataAccess.FRead(FN.PARAM,Y.PARAM.ID,R.PARAM, F.PARAM, ER.PARAM)
    Y.DEPOSIT.PARTICULAR = R.PARAM<MBL.TXN.DEPOSIT.PARTICULAR>
    Y.TOT.DEP.TXN.CODE = R.PARAM<MBL.TXN.DEP.TXN.CODE>
    IF Y.SYS.ID EQ 'TT' THEN
        Y.TRANS.CODE = TT.Config.TellerTransaction.TrTransactionCodeTwo
        Y.TRANS.CODE.ONE = TT.Config.TellerTransaction.TrTransactionCodeOne
    END ELSE
        IF Y.SYS.ID EQ 'FT' THEN
            Y.TRANS.TYPE = FT.Contract.getIdTxnType()
            EB.DataAccess.FRead(FN.FT.TYPE, Y.TRANS.TYPE, R.FT.TYPE, F.FT.TYPE, Y.ERR)
            Y.TRANS.CODE = R.FT.TYPE<FT.Config.TxnTypeCondition.FtSixTxnCodeCr>
        END
    END
    Y.DATA = Y.AC.NO:'*':'Y.DEPOSIT.PARTICULAR=':Y.DEPOSIT.PARTICULAR:'*':'Y.TRANS.CODE='Y.TRANS.CODE:'*':Y.SYS.ID:'*':Y.TOT.DEP.TXN.CODE:'*':Y.TRANS.CODE.ONE
    Y.DIR = 'MBL.DATA'
    Y.FILE.NAME = 'TP'
    OPENSEQ Y.DIR,Y.FILE.NAME TO F.DIR THEN NULL
    WRITESEQ Y.DATA APPEND TO F.DIR ELSE
        CRT "Unable to write"
        CLOSESEQ F.DIR
    END
    FIND Y.TRANS.CODE IN Y.TOT.DEP.TXN.CODE SETTING TXN.POS1,TXN.POS2,TXN.POS3 THEN
        Y.PARTICULAR = FIELD(Y.DEPOSIT.PARTICULAR,VM,TXN.POS2)
    END
    IF Y.RECORD.STATUS EQ 'UNAUTH' THEN
        GOSUB PROCESS.DEPOSIT
    END
    IF Y.RECORD.STATUS EQ 'DELETE'  OR Y.RECORD.STATUS EQ 'AUTH-REV' THEN
        GOSUB REMOVE.DEP.OVRR.INFO
    END
RETURN
****************
PROCESS.DEPOSIT:
****************
***********Write TP Transaction Information Data Into BD.TXN.PROFILE.ENTRY***************
    GOSUB GET.TP.INFO
    IF  NOT(R.TP.REC) THEN
        Y.OVERR.ID = 'EB-MBL.TP.DEFAULT'
        EB.SystemTables.setText(Y.OVERR.ID)
        Y.OVERRIDE.VAL = EB.SystemTables.getRNew(V-9)
        Y.OVRRD.NO = DCOUNT(Y.OVERRIDE.VAL,VM) + 1
        EB.OverrideProcessing.StoreOverride(Y.OVRRD.NO)
        RETURN
    END
    ELSE
        GOSUB DEPOSIT.PART
        FINDSTR Y.PARTICULAR IN Y.DEPOSIT.PART SETTING Y.DEP.POS1,Y.DEP.POS2,Y.DEP.POS3 THEN END
          
        IF Y.DEP.POS1 EQ 1 THEN
            Y.DEP.NO.TXN.MON = R.TP.REC<MB.TP.CASH.DEP.NO>
            Y.DEP.MAX.TXN.AMT = R.TP.REC<MB.TP.CASH.DEP.AMT>
            Y.DEP.TOT.AMT = R.TP.REC<MB.TP.CASH.DEP.MAX>
       
            R.TP.ENTRY<MBLTPE.CASH.DEP.OCCPY.TXN> = R.TP.ENTRY<MBLTPE.CASH.DEP.OCCPY.TXN> + 1
            Y.DEP.TOT.TXN = R.TP.ENTRY<MBLTPE.CASH.DEP.OCCPY.TXN>
            IF R.TP.ENTRY<MBLTPE.CASH.DEP.TXN.REF> EQ '' THEN
                R.TP.ENTRY<MBLTPE.CASH.DEP.TXN.REF> = Y.TXN.REF
            END ELSE
                R.TP.ENTRY<MBLTPE.CASH.DEP.TXN.REF> = R.TP.ENTRY<MBLTPE.CASH.DEP.TXN.REF>:'*':Y.TXN.REF
            END
            IF  R.TP.ENTRY<MBLTPE.CASH.DEP.TXN.AMT> EQ '' THEN
                R.TP.ENTRY<MBLTPE.CASH.DEP.TXN.AMT> = Y.TXN.AMT
            END ELSE
                R.TP.ENTRY<MBLTPE.CASH.DEP.TXN.AMT> = R.TP.ENTRY<MBLTPE.CASH.DEP.TXN.AMT>:'*':Y.TXN.AMT
            END
            R.TP.ENTRY<MBLTPE.CASH.DEP.TOT.TXN.AMT> = R.TP.ENTRY<MBLTPE.CASH.DEP.TOT.TXN.AMT> + Y.TXN.AMT
            Y.TOT.TXN.AMT = R.TP.ENTRY<MBLTPE.CASH.DEP.TOT.TXN.AMT>
        END
        IF Y.DEP.POS1 EQ 2 THEN
            Y.DEP.NO.TXN.MON = R.TP.REC<MB.TP.TRF.DEP.NO>
            Y.DEP.MAX.TXN.AMT = R.TP.REC<MB.TP.TRF.DEP.AMT>
            Y.DEP.TOT.AMT = R.TP.REC<MB.TP.TRF.DEP.MAX>
            
            R.TP.ENTRY<MBLTPE.TRF.DEP.OCCPY.TXN> = R.TP.ENTRY<MBLTPE.TRF.DEP.OCCPY.TXN> + 1
            Y.DEP.TOT.TXN = R.TP.ENTRY<MBLTPE.TRF.DEP.OCCPY.TXN>
            IF R.TP.ENTRY<MBLTPE.TRF.DEP.TXN.REF> EQ '' THEN
                R.TP.ENTRY<MBLTPE.TRF.DEP.TXN.REF> = Y.TXN.REF
            END ELSE
                R.TP.ENTRY<MBLTPE.TRF.DEP.TXN.REF> = R.TP.ENTRY<MBLTPE.TRF.DEP.TXN.REF>:'*':Y.TXN.REF
            END
            IF  R.TP.ENTRY<MBLTPE.TRF.DEP.TXN.AMT> EQ '' THEN
                R.TP.ENTRY<MBLTPE.TRF.DEP.TXN.AMT> = Y.TXN.AMT
            END ELSE
                R.TP.ENTRY<MBLTPE.TRF.DEP.TXN.AMT> = R.TP.ENTRY<MBLTPE.TRF.DEP.TXN.AMT>:'*':Y.TXN.AMT
            END
            R.TP.ENTRY<MBLTPE.TRF.DEP.TOT.TXN.AMT> = R.TP.ENTRY<MBLTPE.TRF.DEP.TOT.TXN.AMT> + Y.TXN.AMT
            Y.TOT.TXN.AMT = R.TP.ENTRY<MBLTPE.TRF.DEP.TOT.TXN.AMT>
        END
        IF Y.DEP.POS1 EQ 3 THEN
            Y.DEP.NO.TXN.MON = R.TP.REC<MB.TP.RMT.DEP.NO>
            Y.DEP.MAX.TXN.AMT = R.TP.REC<MB.TP.RMT.DEP.AMT>
            Y.DEP.TOT.AMT = R.TP.REC<MB.TP.RMT.DEP.MAX>
            
            R.TP.ENTRY<MBLTPE.RMT.DEP.OCCPY.TXN> = R.TP.ENTRY<MBLTPE.RMT.DEP.OCCPY.TXN> + 1
            Y.DEP.TOT.TXN = R.TP.ENTRY<MBLTPE.RMT.DEP.OCCPY.TXN>
            IF R.TP.ENTRY<MBLTPE.RMT.DEP.TXN.REF> EQ '' THEN
                R.TP.ENTRY<MBLTPE.RMT.DEP.TXN.REF> = Y.TXN.REF
            END ELSE
                R.TP.ENTRY<MBLTPE.RMT.DEP.TXN.REF> = R.TP.ENTRY<MBLTPE.RMT.DEP.TXN.REF>:'*':Y.TXN.REF
            END
            IF  R.TP.ENTRY<MBLTPE.RMT.DEP.TXN.AMT> EQ '' THEN
                R.TP.ENTRY<MBLTPE.RMT.DEP.TXN.AMT> = Y.TXN.AMT
            END ELSE
                R.TP.ENTRY<MBLTPE.RMT.DEP.TXN.AMT> = R.TP.ENTRY<MBLTPE.RMT.DEP.TXN.AMT>:'*':Y.TXN.AMT
            END
            R.TP.ENTRY<MBLTPE.RMT.DEP.TOT.TXN.AMT> = R.TP.ENTRY<MBLTPE.RMT.DEP.TOT.TXN.AMT> + Y.TXN.AMT
            Y.TOT.TXN.AMT = R.TP.ENTRY<MBLTPE.RMT.DEP.TOT.TXN.AMT>
        END
        IF Y.DEP.POS1 EQ 4 THEN
            Y.DEP.NO.TXN.MON = R.TP.REC<MB.TP.EXP.DEP.NO>
            Y.DEP.MAX.TXN.AMT = R.TP.REC<MB.TP.EXP.DEP.AMT>
            Y.DEP.TOT.AMT = R.TP.REC<MB.TP.EXP.DEP.MAX>
            
            R.TP.ENTRY<MBLTPE.EXP.DEP.OCCPY.TXN> = R.TP.ENTRY<MBLTPE.EXP.DEP.OCCPY.TXN> + 1
            Y.DEP.TOT.TXN = R.TP.ENTRY<MBLTPE.EXP.DEP.OCCPY.TXN>
            IF R.TP.ENTRY<MBLTPE.EXP.DEP.TXN.REF> EQ '' THEN
                R.TP.ENTRY<MBLTPE.EXP.DEP.TXN.REF> = Y.TXN.REF
            END ELSE
                R.TP.ENTRY<MBLTPE.EXP.DEP.TXN.REF> = R.TP.ENTRY<MBLTPE.EXP.DEP.TXN.REF>:'*':Y.TXN.REF
            END
            IF  R.TP.ENTRY<MBLTPE.EXP.DEP.TXN.AMT> EQ '' THEN
                R.TP.ENTRY<MBLTPE.EXP.DEP.TXN.AMT> = Y.TXN.AMT
            END ELSE
                R.TP.ENTRY<MBLTPE.EXP.DEP.TXN.AMT> = R.TP.ENTRY<MBLTPE.EXP.DEP.TXN.AMT>:'*':Y.TXN.AMT
            END
            R.TP.ENTRY<MBLTPE.EXP.DEP.TOT.TXN.AMT> = R.TP.ENTRY<MBLTPE.EXP.DEP.TOT.TXN.AMT> + Y.TXN.AMT
            Y.TOT.TXN.AMT = R.TP.ENTRY<MBLTPE.EXP.DEP.TOT.TXN.AMT>
        END
        IF Y.DEP.POS1 EQ 5 THEN
            Y.DEP.NO.TXN.MON = R.TP.REC<MB.TP.BOA.DEP.NO>
            Y.DEP.MAX.TXN.AMT = R.TP.REC<MB.TP.BOA.DEP.AMT>
            Y.DEP.TOT.AMT = R.TP.REC<MB.TP.BOA.DEP.MAX>
            
            R.TP.ENTRY<MBLTPE.BOA.DEP.OCCPY.TXN> = R.TP.ENTRY<MBLTPE.BOA.DEP.OCCPY.TXN> + 1
            Y.DEP.TOT.TXN = R.TP.ENTRY<MBLTPE.BOA.DEP.OCCPY.TXN>
            IF R.TP.ENTRY<MBLTPE.BOA.DEP.TXN.REF> EQ '' THEN
                R.TP.ENTRY<MBLTPE.BOA.DEP.TXN.REF> = Y.TXN.REF
            END ELSE
                R.TP.ENTRY<MBLTPE.BOA.DEP.TXN.REF> = R.TP.ENTRY<MBLTPE.BOA.DEP.TXN.REF>:'*':Y.TXN.REF
            END
            IF  R.TP.ENTRY<MBLTPE.BOA.DEP.TXN.AMT> EQ '' THEN
                R.TP.ENTRY<MBLTPE.BOA.DEP.TXN.AMT> = Y.TXN.AMT
            END ELSE
                R.TP.ENTRY<MBLTPE.BOA.DEP.TXN.AMT> = R.TP.ENTRY<MBLTPE.BOA.DEP.TXN.AMT>:'*':Y.TXN.AMT
            END
            R.TP.ENTRY<MBLTPE.BOA.DEP.TOT.TXN.AMT> = R.TP.ENTRY<MBLTPE.BOA.DEP.TOT.TXN.AMT> + Y.TXN.AMT
            Y.TOT.TXN.AMT = R.TP.ENTRY<MBLTPE.BOA.DEP.TOT.TXN.AMT>
        END
        IF Y.DEP.POS1 EQ 6 THEN
            Y.DEP.NO.TXN.MON = R.TP.REC<MB.TP.OTH.DEP.NO>
            Y.DEP.MAX.TXN.AMT = R.TP.REC<MB.TP.OTH.DEP.AMT>
            Y.DEP.TOT.AMT = R.TP.REC<MB.TP.OTH.DEP.MAX>
            
            R.TP.ENTRY<MBLTPE.OTH.DEP.OCCPY.TXN> = R.TP.ENTRY<MBLTPE.OTH.DEP.OCCPY.TXN> + 1
            Y.DEP.TOT.TXN = R.TP.ENTRY<MBLTPE.OTH.DEP.OCCPY.TXN>
            IF R.TP.ENTRY<MBLTPE.OTH.DEP.TXN.REF> EQ '' THEN
                R.TP.ENTRY<MBLTPE.OTH.DEP.TXN.REF> = Y.TXN.REF
            END ELSE
                R.TP.ENTRY<MBLTPE.OTH.DEP.TXN.REF> = R.TP.ENTRY<MBLTPE.OTH.DEP.TXN.REF>:'*':Y.TXN.REF
            END
            IF  R.TP.ENTRY<MBLTPE.OTH.DEP.TXN.AMT> EQ '' THEN
                R.TP.ENTRY<MBLTPE.OTH.DEP.TXN.AMT> = Y.TXN.AMT
            END ELSE
                R.TP.ENTRY<MBLTPE.OTH.DEP.TXN.AMT> = R.TP.ENTRY<MBLTPE.OTH.DEP.TXN.AMT>:'*':Y.TXN.AMT
            END
            R.TP.ENTRY<MBLTPE.OTH.DEP.TOT.TXN.AMT> = R.TP.ENTRY<MBLTPE.OTH.DEP.TOT.TXN.AMT> + Y.TXN.AMT
            Y.TOT.TXN.AMT = R.TP.ENTRY<MBLTPE.OTH.DEP.TOT.TXN.AMT>
        END
        WRITE R.TP.ENTRY ON F.TP.ENTRY,Y.TP.ENTRY.ID
        GOSUB WRITE.DEP.OVRR.MSG
    END
RETURN
************
GET.TP.INFO:
************

***********Read TP Record***************
    EB.DataAccess.FRead(FN.TP,Y.AC.NO,R.TP.REC,F.TP,TP.ERR)
    IF R.TP.REC NE '' THEN
        Y.TP.ENTRY.ID = Y.AC.NO:'.':EB.SystemTables.getToday()[1,6]
        EB.DataAccess.FRead(FN.TP.ENTRY,Y.TP.ENTRY.ID,R.TP.ENTRY,F.TP.ENTRY,TP.ERR.ENTRY)
        IF R.TP.ENTRY NE '' THEN
            RETURN
        END
        ELSE
            R.TP.ENTRY<MBLTPE.HDR.DEP.CSH> = 'Cash Deposit (Inc of Online/ATM)'
            R.TP.ENTRY<MBLTPE.HDR.DEP.TRF> = 'Transfer/ Deposit by Instruments'
            R.TP.ENTRY<MBLTPE.HDR.DEP.RMT> = 'Foreign Inward Remittance'
            R.TP.ENTRY<MBLTPE.HDR.DEP.EXP> = 'Receipt of Export Proceed'
            R.TP.ENTRY<MBLTPE.HDR.DEP.BOA> = 'Deposit/Transfer From BO Account'
            R.TP.ENTRY<MBLTPE.HDR.DEP.OTH> = 'Others'
            R.TP.ENTRY<MBLTPE.CO.CODE> = EB.SystemTables.getIdCompany()
        END
    END
RETURN
*************
DEPOSIT.PART:
*************
    Y.DEPOSIT.PART = ''
    IF R.TP.REC<MB.TP.CASH.DEP.NO> THEN
        Y.DEPOSIT.PART = 'Cash Deposit (Inc of Online/ATM)'
    END
    IF R.TP.REC<MB.TP.TRF.DEP.NO> THEN
        Y.DEPOSIT.PART = 'Cash Deposit (Inc of Online/ATM)':FM:'Transfer/ Deposit by Instruments'
    END
    IF R.TP.REC<MB.TP.RMT.DEP.NO> THEN
        Y.DEPOSIT.PART = 'Cash Deposit (Inc of Online/ATM)':FM:'Transfer/ Deposit by Instruments':FM:'Foreign Inward Remittance'
    END

    IF R.TP.REC<MB.TP.EXP.DEP.NO> THEN
        Y.DEPOSIT.PART = 'Cash Deposit (Inc of Online/ATM)':FM:'Transfer/ Deposit by Instruments':FM:'Foreign Inward Remittance':FM:'Receipt of Export Proceed'
    END

    IF R.TP.REC<MB.TP.BOA.DEP.NO> THEN
        Y.DEPOSIT.PART = 'Cash Deposit (Inc of Online/ATM)':FM:'Transfer/ Deposit by Instruments':FM:'Foreign Inward Remittance':FM:'Receipt of Export Proceed':FM:'Deposit/Transfer From BO Account'
    END

    IF R.TP.REC<MB.TP.OTH.DEP.NO> THEN
        Y.DEPOSIT.PART = 'Cash Deposit (Inc of Online/ATM)':FM:'Transfer/ Deposit by Instruments':FM:'Foreign Inward Remittance':FM:'Receipt of Export Proceed':FM:'Deposit/Transfer From BO Account':FM:'Others'
    END
RETURN

*******************
WRITE.DEP.OVRR.MSG:
*******************
    IF Y.TXN.AMT GT Y.DEP.MAX.TXN.AMT THEN
        Y.OR.ID = 'EB-MBL.TP.AMT.DEP'
        EB.DataAccess.FRead(FN.OR,Y.OR.ID,R.OVERRIDE,F.OR,E.OVERRIDE)
        Y.OVERR.ID = R.OVERRIDE<EB.OverrideProcessing.Override.OrMessage>
        Y.OVERR.ID.AC = Y.OVERR.ID:' ': Y.AC.NO
        EB.SystemTables.setText(Y.OVERR.ID.AC)
        Y.OVERRIDE.VAL = EB.SystemTables.getRNew(V-9)
        Y.OVRRD.NO = DCOUNT(Y.OVERRIDE.VAL,VM) + 1
        EB.OverrideProcessing.StoreOverride(Y.OVRRD.NO)
    END
    
    IF Y.DEP.TOT.TXN GT Y.DEP.NO.TXN.MON THEN
        Y.OR.ID = 'EB-MBL.TP.TXN.DEP'
        EB.DataAccess.FRead(FN.OR,Y.OR.ID,R.OVERRIDE,F.OR,E.OVERRIDE)
        Y.OVERR.ID = R.OVERRIDE<EB.OverrideProcessing.Override.OrMessage>
        Y.OVERR.ID.AC = Y.OVERR.ID:' ': Y.AC.NO
        EB.SystemTables.setText(Y.OVERR.ID.AC)
        Y.OVERRIDE.VAL = EB.SystemTables.getRNew(V-9)
        Y.OVRRD.NO = DCOUNT(Y.OVERRIDE.VAL,VM) + 1
        EB.OverrideProcessing.StoreOverride(Y.OVRRD.NO)
    END

    IF Y.TOT.TXN.AMT GT Y.DEP.TOT.AMT THEN
        Y.OR.ID = 'EB-MBL.TP.TOT.AMT.DEP'
        EB.DataAccess.FRead(FN.OR,Y.OR.ID,R.OVERRIDE,F.OR,E.OVERRIDE)
        Y.OVERR.ID = R.OVERRIDE<EB.OverrideProcessing.Override.OrMessage>
        Y.OVERR.ID.AC = Y.OVERR.ID:' ': Y.AC.NO
        EB.SystemTables.setText(Y.OVERR.ID.AC)
        Y.OVERRIDE.VAL = EB.SystemTables.getRNew(V-9)
        Y.OVRRD.NO = DCOUNT(Y.OVERRIDE.VAL,VM) + 1
        EB.OverrideProcessing.StoreOverride(Y.OVRRD.NO)
    END
RETURN
*********************
REMOVE.DEP.OVRR.INFO:
*********************
    Y.TP.ENTRY.ID = Y.AC.NO:'.':EB.SystemTables.getToday()[1,6]
    EB.DataAccess.FRead(FN.TP.ENTRY,Y.TP.ENTRY.ID,R.TP.ENTRY,F.TP.ENTRY,TP.ERR.ENTRY)
    EB.DataAccess.FRead(FN.TP,Y.AC.NO,R.TP.REC,F.TP,TP.ERR)
    IF R.TP.ENTRY THEN
        GOSUB DEPOSIT.PART
        FINDSTR Y.PARTICULAR  IN Y.DEPOSIT.PART SETTING Y.DEP.POS1,Y.DEP.POS2,Y.DEP.POS3 ELSE NULL
       
        IF Y.DEP.POS1 EQ 1 THEN
            Y.OCCPY.TXNS = R.TP.ENTRY<MBLTPE.CASH.DEP.OCCPY.TXN> -1
            FINDSTR Y.TXN.REF:'*' IN R.TP.ENTRY<MBLTPE.CASH.DEP.TXN.REF> SETTING Y.POS1 ELSE NULL
            IF Y.POS1 THEN
                Y.TXN.REF.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.CASH.DEP.TXN.REF>,Y.TXN.REF:'*','')
                Y.TXN.AMT.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.CASH.DEP.TXN.AMT>,Y.TXN.AMT:'*','')
            END ELSE
                FINDSTR '*' IN R.TP.ENTRY<MBLTPE.CASH.DEP.TXN.REF> SETTING Y.DM.POS1 ELSE NULL
                IF NOT(Y.DM.POS1) THEN
                    Y.TXN.REF.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.CASH.DEP.TXN.REF>,Y.TXN.REF,'')
                    Y.TXN.AMT.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.CASH.DEP.TXN.AMT>,Y.TXN.AMT,'')
                END ELSE
                    Y.TXN.REF.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.CASH.DEP.TXN.REF>,'*':Y.TXN.REF,'')
                    Y.TXN.AMT.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.CASH.DEP.TXN.AMT>,'*':Y.TXN.AMT,'')
                END
            END
            IF Y.TXN.REF.REPLACE.VALUE NE 0 AND Y.TXN.AMT.REPLACE.VALUE NE 0 THEN
                R.TP.ENTRY<MBLTPE.CASH.DEP.OCCPY.TXN> = Y.OCCPY.TXNS
                R.TP.ENTRY<MBLTPE.CASH.DEP.TXN.REF> = Y.TXN.REF.REPLACE.VALUE
                R.TP.ENTRY<MBLTPE.CASH.DEP.TXN.AMT> = Y.TXN.AMT.REPLACE.VALUE
                R.TP.ENTRY<MBLTPE.CASH.DEP.TOT.TXN.AMT> = R.TP.ENTRY<MBLTPE.CASH.DEP.TOT.TXN.AMT> - Y.TXN.AMT
                Y.TOT.AMT =  R.TP.ENTRY<MBLTPE.CASH.DEP.TOT.TXN.AMT>
            END
        END
        IF Y.DEP.POS1 EQ 2 THEN
            Y.OCCPY.TXNS = R.TP.ENTRY<MBLTPE.TRF.DEP.OCCPY.TXN> -1
            FINDSTR Y.TXN.REF:'*' IN R.TP.ENTRY<MBLTPE.TRF.DEP.TXN.REF> SETTING Y.POS1 ELSE NULL
            IF Y.POS1 THEN
                Y.TXN.REF.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.TRF.DEP.TXN.REF>,Y.TXN.REF:'*','')
                Y.TXN.AMT.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.TRF.DEP.TXN.AMT>,Y.TXN.AMT:'*','')
            END ELSE
                FINDSTR '*' IN R.TP.ENTRY<MBLTPE.TRF.DEP.TXN.REF> SETTING Y.DM.POS1 ELSE NULL
                IF NOT(Y.DM.POS1) THEN
                    Y.TXN.REF.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.TRF.DEP.TXN.REF>,Y.TXN.REF,'')
                    Y.TXN.AMT.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.TRF.DEP.TXN.AMT>,Y.TXN.AMT,'')
                END ELSE
                    Y.TXN.REF.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.TRF.DEP.TXN.REF>,'*':Y.TXN.REF,'')
                    Y.TXN.AMT.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.TRF.DEP.TXN.AMT>,'*':Y.TXN.AMT,'')
                END
            END
            IF Y.TXN.REF.REPLACE.VALUE NE 0 AND Y.TXN.AMT.REPLACE.VALUE NE 0 THEN
                R.TP.ENTRY<MBLTPE.TRF.DEP.OCCPY.TXN> = Y.OCCPY.TXNS
                R.TP.ENTRY<MBLTPE.TRF.DEP.TXN.REF> = Y.TXN.REF.REPLACE.VALUE
                R.TP.ENTRY<MBLTPE.TRF.DEP.TXN.AMT> = Y.TXN.AMT.REPLACE.VALUE
                R.TP.ENTRY<MBLTPE.TRF.DEP.TOT.TXN.AMT> = R.TP.ENTRY<MBLTPE.TRF.DEP.TOT.TXN.AMT> - Y.TXN.AMT
            END
        END
        IF Y.DEP.POS1 EQ 3 THEN
            Y.OCCPY.TXNS = R.TP.ENTRY<MBLTPE.RMT.DEP.OCCPY.TXN> -1
            FINDSTR Y.TXN.REF:'*' IN R.TP.ENTRY<MBLTPE.RMT.DEP.TXN.REF> SETTING Y.POS1 ELSE NULL
            IF Y.POS1 THEN
                Y.TXN.REF.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.RMT.DEP.TXN.REF>,Y.TXN.REF:'*','')
                Y.TXN.AMT.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.RMT.DEP.TXN.AMT>,Y.TXN.AMT:'*','')
            END ELSE
                FINDSTR '*' IN R.TP.ENTRY<MBLTPE.RMT.DEP.TXN.REF> SETTING Y.DM.POS1 ELSE NULL
                IF NOT(Y.DM.POS1) THEN
                    Y.TXN.REF.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.RMT.DEP.TXN.REF>,Y.TXN.REF,'')
                    Y.TXN.AMT.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.RMT.DEP.TXN.AMT>,Y.TXN.AMT,'')
                END ELSE
                    Y.TXN.REF.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.RMT.DEP.TXN.REF>,'*':Y.TXN.REF,'')
                    Y.TXN.AMT.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.RMT.DEP.TXN.AMT>,'*':Y.TXN.AMT,'')
                END
            END
            IF Y.TXN.REF.REPLACE.VALUE NE 0 AND Y.TXN.AMT.REPLACE.VALUE NE 0 THEN
                R.TP.ENTRY<MBLTPE.RMT.DEP.OCCPY.TXN> = Y.OCCPY.TXNS
                R.TP.ENTRY<MBLTPE.RMT.DEP.TXN.REF> = Y.TXN.REF.REPLACE.VALUE
                R.TP.ENTRY<MBLTPE.RMT.DEP.TXN.AMT> = Y.TXN.AMT.REPLACE.VALUE
                R.TP.ENTRY<MBLTPE.RMT.DEP.TOT.TXN.AMT> = R.TP.ENTRY<MBLTPE.RMT.DEP.TOT.TXN.AMT> - Y.TXN.AMT
            END
        END
        IF Y.DEP.POS1 EQ 4 THEN
            Y.OCCPY.TXNS = R.TP.ENTRY<MBLTPE.EXP.DEP.OCCPY.TXN> -1
            FINDSTR Y.TXN.REF:'*' IN R.TP.ENTRY<MBLTPE.EXP.DEP.TXN.REF> SETTING Y.POS1 ELSE NULL
            IF Y.POS1 THEN
                Y.TXN.REF.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.EXP.DEP.TXN.REF>,Y.TXN.REF:'*','')
                Y.TXN.AMT.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.EXP.DEP.TXN.AMT>,Y.TXN.AMT:'*','')
            END ELSE
                FINDSTR '*' IN R.TP.ENTRY<MBLTPE.EXP.DEP.TXN.REF> SETTING Y.DM.POS1 ELSE NULL
                IF NOT(Y.DM.POS1) THEN
                    Y.TXN.REF.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.EXP.DEP.TXN.REF>,Y.TXN.REF,'')
                    Y.TXN.AMT.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.EXP.DEP.TXN.AMT>,Y.TXN.AMT,'')
                END ELSE
                    Y.TXN.REF.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.EXP.DEP.TXN.REF>,'*':Y.TXN.REF,'')
                    Y.TXN.AMT.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.EXP.DEP.TXN.AMT>,'*':Y.TXN.AMT,'')
                END
            END
            IF Y.TXN.REF.REPLACE.VALUE NE 0 AND Y.TXN.AMT.REPLACE.VALUE NE 0 THEN
                R.TP.ENTRY<MBLTPE.EXP.DEP.OCCPY.TXN> = Y.OCCPY.TXNS
                R.TP.ENTRY<MBLTPE.EXP.DEP.TXN.REF> = Y.TXN.REF.REPLACE.VALUE
                R.TP.ENTRY<MBLTPE.EXP.DEP.TXN.AMT> = Y.TXN.AMT.REPLACE.VALUE
                R.TP.ENTRY<MBLTPE.EXP.DEP.TOT.TXN.AMT> = R.TP.ENTRY<MBLTPE.EXP.DEP.TOT.TXN.AMT> - Y.TXN.AMT
            END
        END
        IF Y.DEP.POS1 EQ 5 THEN
            Y.OCCPY.TXNS = R.TP.ENTRY<MBLTPE.BOA.DEP.OCCPY.TXN> -1
            FINDSTR Y.TXN.REF:'*' IN R.TP.ENTRY<MBLTPE.BOA.DEP.TXN.REF> SETTING Y.POS1 ELSE NULL
            IF Y.POS1 THEN
                Y.TXN.REF.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.BOA.DEP.TXN.REF>,Y.TXN.REF:'*','')
                Y.TXN.AMT.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.BOA.DEP.TXN.AMT>,Y.TXN.AMT:'*','')
            END ELSE
                FINDSTR '*' IN R.TP.ENTRY<MBLTPE.BOA.DEP.TXN.REF> SETTING Y.DM.POS1 ELSE NULL
                IF NOT(Y.DM.POS1) THEN
                    Y.TXN.REF.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.BOA.DEP.TXN.REF>,Y.TXN.REF,'')
                    Y.TXN.AMT.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.BOA.DEP.TXN.AMT>,Y.TXN.AMT,'')
                END ELSE
                    Y.TXN.REF.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.BOA.DEP.TXN.REF>,'*':Y.TXN.REF,'')
                    Y.TXN.AMT.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.BOA.DEP.TXN.AMT>,'*':Y.TXN.AMT,'')
                END
            END
            IF Y.TXN.REF.REPLACE.VALUE NE 0 AND Y.TXN.AMT.REPLACE.VALUE NE 0 THEN
                R.TP.ENTRY<MBLTPE.BOA.DEP.OCCPY.TXN> = Y.OCCPY.TXNS
                R.TP.ENTRY<MBLTPE.BOA.DEP.TXN.REF> = Y.TXN.REF.REPLACE.VALUE
                R.TP.ENTRY<MBLTPE.BOA.DEP.TXN.AMT> = Y.TXN.AMT.REPLACE.VALUE
                R.TP.ENTRY<MBLTPE.BOA.DEP.TOT.TXN.AMT> = R.TP.ENTRY<MBLTPE.BOA.DEP.TOT.TXN.AMT> - Y.TXN.AMT
            END
        END
        IF Y.DEP.POS1 EQ 6 THEN
            Y.OCCPY.TXNS = R.TP.ENTRY<MBLTPE.OTH.DEP.OCCPY.TXN> -1
            FINDSTR Y.TXN.REF:'*' IN R.TP.ENTRY<MBLTPE.OTH.DEP.TXN.REF> SETTING Y.POS1 ELSE NULL
            IF Y.POS1 THEN
                Y.TXN.REF.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.OTH.DEP.TXN.REF>,Y.TXN.REF:'*','')
                Y.TXN.AMT.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.OTH.DEP.TXN.AMT>,Y.TXN.AMT:'*','')
            END ELSE
                FINDSTR '*' IN R.TP.ENTRY<MBLTPE.OTH.DEP.TXN.REF> SETTING Y.DM.POS1 ELSE NULL
                IF NOT(Y.DM.POS1) THEN
                    Y.TXN.REF.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.OTH.DEP.TXN.REF>,Y.TXN.REF,'')
                    Y.TXN.AMT.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.OTH.DEP.TXN.AMT>,Y.TXN.AMT,'')
                END ELSE
                    Y.TXN.REF.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.OTH.DEP.TXN.REF>,'*':Y.TXN.REF,'')
                    Y.TXN.AMT.REPLACE.VALUE = EREPLACE(R.TP.ENTRY<MBLTPE.OTH.DEP.TXN.AMT>,'*':Y.TXN.AMT,'')
                END
            END
            IF Y.TXN.REF.REPLACE.VALUE NE 0 AND Y.TXN.AMT.REPLACE.VALUE NE 0 THEN
                R.TP.ENTRY<MBLTPE.OTH.DEP.OCCPY.TXN> = Y.OCCPY.TXNS
                R.TP.ENTRY<MBLTPE.OTH.DEP.TXN.REF> = Y.TXN.REF.REPLACE.VALUE
                R.TP.ENTRY<MBLTPE.OTH.DEP.TXN.AMT> = Y.TXN.AMT.REPLACE.VALUE
                R.TP.ENTRY<MBLTPE.OTH.DEP.TOT.TXN.AMT> = R.TP.ENTRY<MBLTPE.OTH.DEP.TOT.TXN.AMT> - Y.TXN.AMT
            END
        END
    
        WRITE R.TP.ENTRY ON F.TP.ENTRY,Y.TP.ENTRY.ID
    END
RETURN
END
