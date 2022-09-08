SUBROUTINE GB.MBL.V.CHQ.ISSUE
*-----------------------------------------------------------------------------
*Subroutine Description:
*For retrieve data from cheque.issue app local field to core field during status 90
*Subroutine Type:
*Attached To    : version(CHEQUE.ISSUE,MBL.INPUT)
*Attached As    : INPUT ROUTINE
*-----------------------------------------------------------------------------
* Modification History :
* 17/02/2020 -                            NEW   - Sarowar Mortoza
*                                                     FDS Pvt Ltd
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $USING ST.ChqIssue
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING EB.Foundation
*-----------------------------------------------------------------------------
    GOSUB INITIALISE ; *FILE INITIALIZATION
    GOSUB OPENFILE ; *OPEN FILE
    GOSUB PROCESS ; *PROCESS THE BUSINESS LOGIC
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>FILE INITIALIZATION </desc>
    FN.CHQ.ISSUE="F.CHEQUE.ISSUE"
    F.CHQ.ISSUE=""
    Y.CHQ.ID=''
    Y.CHQ.ID=EB.SystemTables.getIdNew()
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= OPENFILE>
OPENFILE:
*** <desc>OPEN FILE </desc>
    EB.DataAccess.Opf(FN.CHQ.ISSUE, F.CHQ.ISSUE)
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>PROCESS THE BUSINESS LOGIC </desc>
    Y.CHQ.LEAFNO.POS=""
    Y.CHQ.START.NO.POS=""
    Y.APP.NAME ="CHEQUE.ISSUE"
    LOCAL.FIELDS = ""
    LOCAL.FIELDS = "LT.CHQ.LEAF.NO":VM:"LT.CHQ.NO.START"
    FLD.POS = ""
    EB.Foundation.MapLocalFields(Y.APP.NAME, LOCAL.FIELDS,FLD.POS)
    Y.CHQ.LEAFNO.POS=FLD.POS<1,1>
    Y.CHQ.START.NO.POS=FLD.POS<1,2>
    
    EB.DataAccess.FRead(FN.CHQ.ISSUE, Y.CHQ.ID, R.CHQ, F.CHQ.ISSUE, Y.Erro)
    
    Y.CHQ.LEAF.NO=R.CHQ<ST.ChqIssue.ChequeIssue.ChequeIsLocalRef, Y.CHQ.LEAFNO.POS>
    EB.SystemTables.setRNew(ST.ChqIssue.ChequeIssue.ChequeIsNumberIssued, Y.CHQ.LEAF.NO)
    Y.CHQ.START.NO=R.CHQ<ST.ChqIssue.ChequeIssue.ChequeIsLocalRef, Y.CHQ.START.NO.POS>
    EB.SystemTables.setRNew(ST.ChqIssue.ChequeIssue.ChequeIsChqNoStart, Y.CHQ.START.NO)
        
RETURN
*** </region>

END



