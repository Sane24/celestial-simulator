using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class visability : MonoBehaviour
{
    [SerializeField] private Toggle _toggle;
    [SerializeField] private List<Material> targetMaterials = new List<Material>();
    bool visable = true;

    // Start is called before the first frame update
    void Start()
    {  
        _toggle.onValueChanged.AddListener((v) => {
            if(_toggle.isOn){
                visable = true;
            } else {
                visable = false;
            }
            toggleVisability(visable);
        });
    }

    public void toggleVisability(bool visible)
    {
        Renderer[] allRenderers = FindObjectsOfType<Renderer>();

        for (int i = 0; i < allRenderers.Length; i++)
        {
            Renderer rend = allRenderers[i];
            Material[] materials = rend.sharedMaterials;

            if (materials != null)
            {
                for (int j = 0; j < materials.Length; j++)
                {
                    if (targetMaterials.Contains(materials[j]))
                    {
                        rend.enabled = visible;
                        break;
                    }
                }
            }
        }
    }


}
