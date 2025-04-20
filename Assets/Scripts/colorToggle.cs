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
    // private static colorToggle myscript;
    // Start is called before the first frame update
    void Start()
    {
        
        baseColor = auroraMat.GetColor("_MainColor");
        secondColor = auroraMat.GetColor("_SecondaryColor");
        _slider.onValueChanged.AddListener((v) => {
           _sliderText.text = $"Hue: {v:F2}";
            UpdateColor(v);
        });
    }

    void UpdateColor(float hue)
    {
        Color.RGBToHSV(baseColor, out float h, out float s, out float v);
        Color newColor = Color.HSVToRGB(hue, s, v);
        Color newColorSec = Color.HSVToRGB(hue, s, v);
        auroraMat.SetColor("_MainColor", newColor);
        auroraMat.SetColor("_SecondaryColor", newColorSec);
    }

}
