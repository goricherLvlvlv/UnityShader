using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LiquidBottle : MonoBehaviour
{
    [Range(0, 1)]
    public float FillAmount;

    private MaterialPropertyBlock properties;

    private void Awake()
    {
        properties = new MaterialPropertyBlock();
    }

    private void Start()
    {
        SetFillAmount();
    }

    void Update()
    {
        if (transform.hasChanged)
        {
            properties.SetFloat("_Height", transform.position.y);
            if (TryGetComponent(out MeshRenderer component))
            {
                component.SetPropertyBlock(properties);
            }
        }        
    }

    public void SetFillAmount()
    {
        properties.SetFloat("_FillAmount", -FillAmount * 3 + 2);
        if (TryGetComponent(out MeshRenderer component))
        {
            component.SetPropertyBlock(properties);
        }
    }
}
