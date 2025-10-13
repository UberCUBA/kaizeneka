using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;

namespace KaizenekaApi.Controllers
{
    [ApiController]
    [Authorize]
    [Route("api/[controller]")]
    public class RecursosController : ControllerBase
    {
        [HttpGet]
        public IActionResult GetRecursos()
        {
            var recursos = new List<object>
            {
                new { id = 1, titulo = "Ayuno Intermitente Sobrado", tipo = "video", url = "https://cdn.tuservidor.com/videos/ayuno.mp4" },
                new { id = 2, titulo = "Meditación Ninja", tipo = "audio", url = "https://cdn.tuservidor.com/audios/meditacion.mp3" }
            };
            return Ok(recursos);
        }
    }
}