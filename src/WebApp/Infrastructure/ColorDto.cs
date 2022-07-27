namespace WebApp.Messages
{
    public class ColorDto
    {
        public int Red { get; set; }
        public int Green { get; set; }
        public int Blue { get; set; }

        public override string ToString()
        {
            return $"{Red}, {Green}, {Blue}";
        }
    }
}
