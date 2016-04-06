class Trials {
  static void generateTrials() {
    for (int j=0; j<10; j++) {
      String t = "";
      int start, end;
      int rand = new Double(300* Math.random()).intValue();
      start = rand;
      for (int i=0; i<rand; i++) {
        t+="*";
      }
      rand = new Double((200)* Math.random()+26).intValue();
      end = start + rand;
      for (int i=0; i<rand; i++) {
        t+="@";
      }
      
      while (t.length ()<640) {
        t+="*";
      }
      trialGoals[j][0] = start;
      trialGoals[j][1] = end;
      trialText[j] = t;
      System.out.println(start + " " + end);
    }
  }
  static String[] trialText = {
    "", "*"
      + "*******************************************************************************************************************************"
      + "***************************************************************************************************************"
      + "*****************************************************************************************************"
      + "********************************************************************************************************************************"
      + "*****************************@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@***************************************************************************************************", "*"
      + "***************************************************************@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@****************************************************************"
      + "***************************************************************************************************************"
      + "*****************************************************************************************************"
      + "********************************************************************************************************************************"
      + "********************************************************************************************************************************", "*"
      + "*******************************************************************************************************************************"
      + "***************************************************************************************************************"
      + "*****************************************************************************************************"
      + "*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*******************************************************************************************************************************"
      + "********************************************************************************************************************************", "*"
      + "****@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@***************************************************************************************************************************"
      + "***************************************************************************************************************"
      + "*****************************************************************************************************"
      + "********************************************************************************************************************************"
      + "********************************************************************************************************************************", "*"
      + "*******************************************************************************************************************************"
      + "***************************************************************************************************************"
      + "*****************************************************************************@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@************************"
      + "********************************************************************************************************************************"
      + "********************************************************************************************************************************", "*"
      + "*******************************************************************************************************************************"
      + "*****************************************************************@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@**********************************************"
      + "*****************************************************************************************************"
      + "********************************************************************************************************************************"
      + "********************************************************************************************************************************", "*"
      + "*******************************************************************************************************************************"
      + "***************************************************************************************************************@@@@@@@@@@@@@@@@@"
      + "@@@@@@@@@@@@@@@@@@@@@@@@@@@*****************************************************************************************************"
      + "********************************************************************************************************************************"
      + "********************************************************************************************************************************", "*"
      + "*******************************************************************************************************************************"
      + "***************************************************************************************************************"
      + "*****************************************************************************************************"
      + "********************************************************************************************************************************"
      + "******@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@**************************************************************************************************************************", "*"
      + "*******************************************************************************************************************************"
      + "***************************************************************************************************************"
      + "*****************************************************************************************************"
      + "********************************************************************************************************************************"
      + "**********************************************@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@**********************************************************************************", "FINISHED"
  };


  /*"********************************************************************************************************************************"
   + "***************************************************************************************************************@@@@@@@@@@@@@@@@@"
   + "@@@@@@@@@@@@@@@@@@@@@@@@@@@*****************************************************************************************************"
   + "********************************************************************************************************************************"
   + "********************************************************************************************************************************"*/
  static int[][] trialGoals = {
    {
      239, 283
    }
    , {
      239, 283
    }
    , {
      239, 283
    }
    , {
      239, 283
    }
    , {
      239, 283
    }
    , {
      239, 283
    }
    , {
      239, 283
    }
    , {
      239, 283
    }
    , {
      239, 283
    }
    , {
      239, 283
    }
  };
}

