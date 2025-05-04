using UnityEngine;

[ExecuteAlways]
[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class AuroraCurtainMesh : MonoBehaviour
{
    [Header("Mesh Settings")]
    public int widthSegments = 100;
    public int heightSegments = 20;
    public float width = 20f;
    public float height = 15f;

    [Header("S-Curve Settings")]
    public float waveAmplitude = 4f;
    public float waveFrequency = 2f;

    [Header("Ripple Animation Settings")]
    public float rippleSpeed = 1.0f;
    public float rippleAmplitude = 0.3f;
    public float rippleFrequency = 3.0f;
    public Vector2 rippleDirection = new Vector2(1f, 1f); // (X = horizontal, Y = vertical influence)

    private MeshFilter meshFilter;
    private Mesh mesh;
    private Vector3[] baseVertices;

    void Awake()
    {
        meshFilter = GetComponent<MeshFilter>();
        GenerateMesh();
    }

    void OnValidate()
    {
        if (!Application.isPlaying)
        {
            if (meshFilter == null)
                meshFilter = GetComponent<MeshFilter>();

            GenerateMesh();
        }
    }

    void GenerateMesh()
    {
        mesh = new Mesh();
        mesh.name = "Aurora Curtain Mesh";

        int vertCount = (widthSegments + 1) * (heightSegments + 1);
        Vector3[] vertices = new Vector3[vertCount];
        Vector2[] uvs = new Vector2[vertCount];
        int[] triangles = new int[widthSegments * heightSegments * 6];

        int vertIndex = 0;
        int triIndex = 0;

        for (int y = 0; y <= heightSegments; y++)
        {
            float v = (float)y / heightSegments;
            float yPos = v * height;

            for (int x = 0; x <= widthSegments; x++)
            {
                float u = (float)x / widthSegments;
                float xPos = (u - 0.5f) * width;

                // Curved mesh using sine wave in Z
                float zPos = Mathf.Sin(u * Mathf.PI * waveFrequency) * waveAmplitude;

                vertices[vertIndex] = new Vector3(xPos, yPos, zPos);
                uvs[vertIndex] = new Vector2(u, v);

                if (x < widthSegments && y < heightSegments)
                {
                    int current = vertIndex;
                    int nextRow = current + widthSegments + 1;

                    triangles[triIndex++] = current;
                    triangles[triIndex++] = nextRow;
                    triangles[triIndex++] = current + 1;

                    triangles[triIndex++] = current + 1;
                    triangles[triIndex++] = nextRow;
                    triangles[triIndex++] = nextRow + 1;
                }

                vertIndex++;
            }
        }

        mesh.vertices = vertices;
        mesh.uv = uvs;
        mesh.triangles = triangles;
        mesh.RecalculateNormals();
        mesh.RecalculateBounds();

        meshFilter.mesh = mesh; // not sharedMesh!
        baseVertices = mesh.vertices;
    }

    void Update()
    {
        if (!Application.isPlaying || mesh == null || baseVertices == null)
            return;

        Vector3[] animatedVertices = new Vector3[baseVertices.Length];
        float time = Time.time * rippleSpeed;

        for (int i = 0; i < baseVertices.Length; i++)
        {
            Vector3 baseV = baseVertices[i];

            // Animate based on X and Y world position
            float ripplePhase = (baseV.x * rippleDirection.x + baseV.y * rippleDirection.y) * rippleFrequency + time;

            // amplitude taper (reduce ripple higher up)
            float verticalTaper = Mathf.Lerp(1f, 0.2f, baseV.y / height);

            float ripple = Mathf.Sin(ripplePhase) * rippleAmplitude * verticalTaper;
            baseV.z += ripple;

            animatedVertices[i] = baseV;
        }

        mesh.vertices = animatedVertices;
        mesh.RecalculateNormals();
        mesh.RecalculateBounds();
    }
}
