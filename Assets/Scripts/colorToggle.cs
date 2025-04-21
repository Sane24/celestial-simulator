using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class colorToggle : MonoBehaviour
{
    public Material auroraMat;
    [SerializeField] private Slider _slider;
    [SerializeField] private TextMeshProUGUI _sliderText;
    private Color baseColor;
    private Color secondColor;
    private Color thirdColor;
    // private static colorToggle myscript;
    // Start is called before the first frame update
    void Start()
    {
        
        baseColor = auroraMat.GetColor("_Color1");
        secondColor = auroraMat.GetColor("_Color2");
        thirdColor = auroraMat.GetColor("_Color3");
        _slider.onValueChanged.AddListener((v) => {
           _sliderText.text = $"Hue: {v:F2}";
            UpdateColor(v);
        });
    }

    void UpdateColor(float hue)
    {
        Color.RGBToHSV(baseColor, out float h1, out float s1, out float v1);
        float newH1 = Mathf.Repeat(h1 + hue, 1f);
        Color newColor1 = Color.HSVToRGB(newH1, s1, v1);

        Color.RGBToHSV(secondColor, out float h2, out float s2, out float v2);
        float newH2 = Mathf.Repeat(h2 + hue, 1f);
        Color newColor2 = Color.HSVToRGB(newH2, s2, v2);

        Color.RGBToHSV(thirdColor, out float h3, out float s3, out float v3);
        float newH3 = Mathf.Repeat(h3 + hue, 1f);
        Color newColor3 = Color.HSVToRGB(newH3, s3, v3);

        auroraMat.SetColor("_Color1", newColor1);
        auroraMat.SetColor("_Color2", newColor2);
        auroraMat.SetColor("_Color3", newColor3);
        }

}
