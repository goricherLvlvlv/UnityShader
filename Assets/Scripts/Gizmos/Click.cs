using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Click : MonoBehaviour
{
    public GameObject prefab;
    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            Controller.Instance.InitPoints(Camera.main.ScreenToWorldPoint(Input.mousePosition));
            Controller.Instance.ClearLines();
            Controller.Instance.InitLines();
        }

        else if (Input.GetMouseButtonDown(1))
        {
            Controller.Instance.Clear();
        }
    }
}
