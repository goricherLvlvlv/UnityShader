using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotate : MonoBehaviour
{
    public GameObject cube1;
    public GameObject cube2;
    public GameObject cube3;
    public GameObject cube4;
    public GameObject cube5;
    public GameObject cube6;

    // Start is called before the first frame update
    void Start()
    {
        /* =================================================================================== */
        cube1.transform.Rotate(new Vector3(0.0f, 45.0f, 0.0f), Space.Self);
        cube1.transform.Rotate(new Vector3(60.0f, 0.0f, 0.0f), Space.Self);

        // z=>x=>y, unity底层
        cube2.transform.Rotate(new Vector3(60.0f, 0.0f, 0.0f), Space.World);
        cube2.transform.Rotate(new Vector3(0.0f, 45.0f, 0.0f), Space.World);
        /* =================================================================================== */


        /* =================================================================================== */
        cube3.transform.Rotate(new Vector3(60.0f, 0.0f, 0.0f), Space.World);
        cube3.transform.Rotate(new Vector3(0.0f, 45.0f, 0.0f), Space.World);

        cube4.transform.Rotate(new Vector3(0.0f, 45.0f, 0.0f), Space.World);
        cube4.transform.Rotate(new Vector3(60.0f, 0.0f, 0.0f), Space.World);
        /* =================================================================================== */


        /* =================================================================================== */
        cube5.transform.Rotate(new Vector3(60.0f, 45.0f, 0.0f));

        cube6.transform.Rotate(new Vector3(0.0f, 45.0f, 0.0f), Space.Self);
        cube6.transform.Rotate(new Vector3(60.0f, 0.0f, 0.0f), Space.Self);
        /* =================================================================================== */

    }


}
