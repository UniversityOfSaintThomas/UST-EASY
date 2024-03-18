/**
 * Created by nguy0092 on 3/5/2024.
 */

public with sharing class YN_TEST_CLASS2 {

    public Integer num = 1;

//    public static void newNum(){
//
//        num = 2;
//    }

    public void anotherNum(){

        this.num = 4;
    }

    public void anotherNum2(){

        this.num = this.num + 10;
    }
}