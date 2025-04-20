using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class retainUI : MonoBehaviour
{
    private static retainUI myscript;
    void Awake() {
        if(myscript == null){
            myscript = this;
            DontDestroyOnLoad(myscript);
        } else {
            Destroy(gameObject);
        }
    }
}
